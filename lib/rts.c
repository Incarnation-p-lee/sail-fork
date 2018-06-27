#include<string.h>
#include<getopt.h>
#include<inttypes.h>

#include"sail.h"
#include"rts.h"
#include"elf.h"

static uint64_t g_elf_entry;

void sail_match_failure(sail_string msg)
{
  fprintf(stderr, "Pattern match failure in %s\n", msg);
  exit(EXIT_FAILURE);
}

unit sail_assert(bool b, sail_string msg)
{
  if (b) return UNIT;
  fprintf(stderr, "Assertion failed: %s\n", msg);
  exit(EXIT_FAILURE);
}

unit sail_exit(unit u)
{
  exit(EXIT_SUCCESS);
  return UNIT;
}

bool g_sleeping = false;

unit sleep_request(const unit u)
{
  fprintf(stderr, "Sail CPU model going to sleep\n");
  g_sleeping = true;
  return UNIT;
}

unit wakeup_request(const unit u)
{
  fprintf(stderr, "Sail CPU model waking up\n");
  g_sleeping = false;
  return UNIT;
}

bool sleeping(const unit u)
{
    return g_sleeping;
}

/* ***** Sail memory builtins ***** */

/*
 * We organise memory available to the sail model into a linked list
 * of dynamically allocated MASK + 1 size blocks.
 */
struct block {
  uint64_t block_id;
  uint8_t *mem;
  struct block *next;
};

struct block *sail_memory = NULL;

/*
 * Must be one less than a power of two.
 */
uint64_t MASK = 0xFFFFFFul;

/*
 * All sail vectors are at least 64-bits, but only the bottom 8 bits
 * are used in the second argument.
 */
void write_mem(uint64_t address, uint64_t byte)
{
  //printf("ADDR: %lu, BYTE: %lu\n", address, byte);

  uint64_t mask = address & ~MASK;
  uint64_t offset = address & MASK;

  struct block *current = sail_memory;

  while (current != NULL) {
    if (current->block_id == mask) {
      current->mem[offset] = (uint8_t) byte;
      return;
    } else {
      current = current->next;
    }
  }

  /*
   * If we couldn't find a block matching the mask, allocate a new
   * one, write the byte, and put it at the front of the block list.
   */
  fprintf(stderr, "[Sail] Allocating new block 0x%" PRIx64 "\n", mask);
  struct block *new_block = malloc(sizeof(struct block));
  new_block->block_id = mask;
  new_block->mem = calloc(MASK + 1, sizeof(uint8_t));
  new_block->mem[offset] = (uint8_t) byte;
  new_block->next = sail_memory;
  sail_memory = new_block;
}

uint64_t read_mem(uint64_t address)
{
  uint64_t mask = address & ~MASK;
  uint64_t offset = address & MASK;

  struct block *current = sail_memory;

  while (current != NULL) {
    if (current->block_id == mask) {
      return (uint64_t) current->mem[offset];
    } else {
      current = current->next;
    }
  }

  return 0x00;
}

void kill_mem()
{
  while (sail_memory != NULL) {
    struct block *next = sail_memory->next;

    free(sail_memory->mem);
    free(sail_memory);

    sail_memory = next;
  }
}

// ***** Memory builtins *****

unit write_ram(const mpz_t addr_size,     // Either 32 or 64
	       const mpz_t data_size_mpz, // Number of bytes
	       const sail_bits  hex_ram,       // Currently unused
	       const sail_bits  addr_bv,
	       const sail_bits  data)
{
  uint64_t addr = mpz_get_ui(*addr_bv.bits);
  uint64_t data_size = mpz_get_ui(data_size_mpz);

  mpz_t buf;
  mpz_init_set(buf, *data.bits);

  uint64_t byte;
  for(uint64_t i = 0; i < data_size; ++i) {
    // Take the 8 low bits of buf and write to addr.
    byte = mpz_get_ui(buf) & 0xFF;
    write_mem(addr + i, byte);

    // Then shift buf 8 bits right.
    mpz_fdiv_q_2exp(buf, buf, 8);
  }

  mpz_clear(buf);
  return UNIT;
}

void read_ram(sail_bits *data,
	      const mpz_t addr_size,
	      const mpz_t data_size_mpz,
	      const sail_bits hex_ram,
	      const sail_bits addr_bv)
{
  uint64_t addr = mpz_get_ui(*addr_bv.bits);
  uint64_t data_size = mpz_get_ui(data_size_mpz);

  mpz_set_ui(*data->bits, 0);
  data->len = data_size * 8;

  mpz_t byte;
  mpz_init(byte);
  for(uint64_t i = data_size; i > 0; --i) {
    mpz_set_ui(byte, read_mem(addr + (i - 1)));
    mpz_mul_2exp(*data->bits, *data->bits, 8);
    mpz_add(*data->bits, *data->bits, byte);
  }

  mpz_clear(byte);
}

unit load_raw(mach_bits addr, const sail_string file)
{
  FILE *fp = fopen(file, "r");

  if (!fp) {
    fprintf(stderr, "[Sail] Raw file %s could not be loaded\n", file);
    exit(EXIT_FAILURE);
  }

  uint64_t byte;
  while ((byte = (uint64_t)fgetc(fp)) != EOF) {
    write_mem(addr, byte);
    addr++;
  }

  return UNIT;
}

void load_image(char *file)
{
  FILE *fp = fopen(file, "r");

  if (!fp) {
    fprintf(stderr, "[Sail] Image file %s could not be loaded\n", file);
    exit(EXIT_FAILURE);
  }

  char *addr = NULL;
  char *data = NULL;
  size_t len = 0;

  while (true) {
    ssize_t addr_len = getline(&addr, &len, fp);
    if (addr_len == -1) break;
    ssize_t data_len = getline(&data, &len, fp);
    if (data_len == -1) break;

    if (!strcmp(addr, "elf_entry\n")) {
      if (sscanf(data, "%" PRIu64 "\n", &g_elf_entry) != 1) {
	fprintf(stderr, "[Sail] Failed to parse elf_entry\n");
        exit(EXIT_FAILURE);
      };
      fprintf(stderr, "[Sail] Elf entry point: %" PRIx64 "\n", g_elf_entry);
    } else {
      write_mem((uint64_t) atoll(addr), (uint64_t) atoll(data));
    }
  }

  free(addr);
  free(data);
  fclose(fp);
}

// ***** Tracing support *****

static int64_t g_trace_depth;
//static int64_t g_trace_max_depth;
static bool g_trace_enabled;

unit enable_tracing(const unit u)
{
  g_trace_depth = 0;
  g_trace_enabled = true;
  return UNIT;
}

unit disable_tracing(const unit u)
{
  g_trace_depth = 0;
  g_trace_enabled = false;
  return UNIT;
}

bool is_tracing(const unit u)
{
  return g_trace_enabled;
}

void trace_mach_bits(const mach_bits x) {
  if (g_trace_enabled) fprintf(stderr, "0x%" PRIx64, x);
}

void trace_unit(const unit u) {
  if (g_trace_enabled) fputs("()", stderr);
}

void trace_sail_string(const sail_string str) {
  if (g_trace_enabled) fputs(str, stderr);
}

void trace_sail_int(const sail_int op) {
  if (g_trace_enabled) mpz_out_str(stderr, 10, op);
}

void trace_sail_bits(const sail_bits op) {
  if (g_trace_enabled) fprint_bits("", op, "", stderr);
}

void trace_bool(const bool b) {
  if (g_trace_enabled) {
    if (b) {
      fprintf(stderr, "true");
    } else {
      fprintf(stderr, "false");
    }
  }
}

void trace_unknown(void) {
  if (g_trace_enabled) fputs("?", stderr);
}

void trace_argsep(void) {
  if (g_trace_enabled) fputs(", ", stderr);
}

void trace_argend(void) {
  if (g_trace_enabled) fputs(")\n", stderr);
}

void trace_retend(void) {
  if (g_trace_enabled) fputs("\n", stderr);
}

void trace_start(char *name)
{
  if (g_trace_enabled) {
    fprintf(stderr, "[TRACE] ");
    for (int64_t i = 0; i < g_trace_depth; ++i) {
      fprintf(stderr, "%s", "|   ");
    }
    fprintf(stderr, "%s(", name);
    g_trace_depth++;
  }
}

void trace_end(void)
{
  if (g_trace_enabled) {
    fprintf(stderr, "[TRACE] ");
    for (int64_t i = 0; i < g_trace_depth; ++i) {
      fprintf(stderr, "%s", "|   ");
    }
    g_trace_depth--;
  }
}

/* ***** ELF functions ***** */

void elf_entry(mpz_t *rop, const unit u)
{
  mpz_set_ui(*rop, g_elf_entry);
}

void elf_tohost(mpz_t *rop, const unit u)
{
  mpz_set_ui(*rop, 0x0ul);
}

/* ***** Cycle limit ***** */

static uint64_t g_cycle_count = 0;
static uint64_t g_cycle_limit;

unit cycle_count(const unit u)
{
  if (++g_cycle_count >= g_cycle_limit && g_cycle_limit != 0) {
    printf("\n[Sail] cycle limit %" PRId64 " reached\n", g_cycle_limit);
    exit(EXIT_SUCCESS);
  }

  return UNIT;
}

/* ***** Argument Parsing ***** */

static struct option options[] = {
  {"elf",        required_argument, 0, 'e'},
  {"entry",      required_argument, 0, 'n'},
  {"image",      required_argument, 0, 'i'},
  {"binary",     required_argument, 0, 'b'},
  {"cyclelimit", required_argument, 0, 'l'},
  {"config",     required_argument, 0, 'C'},
  {0, 0, 0, 0}
};

int process_arguments(int argc, char *argv[])
{
  int c;
  bool     elf_entry_set = false;
  uint64_t elf_entry;

  while (true) {
    int option_index = 0;
    c = getopt_long(argc, argv, "e:n:i:b:l:C:", options, &option_index);

    if (c == -1) break;

    switch (c) {
    case 'C': {
        char arg[100];
        uint64_t value;
        if (sscanf(optarg, "%99[a-zA-Z0-9_-.]=%" PRId64, arg, &value)) {
            // do nothing
        } else if (sscanf(optarg, "%99[a-zA-Z0-9_.]=0x%" PRIx64, arg, &value)) {
            // do nothing
        } else {
          fprintf(stderr, "Could not parse argument %s\n", optarg);
          z__ListConfig(UNIT);
          return -1;
        };
        mpz_t s_value;
        mpz_init_set_ui(s_value, value);
        z__SetConfig(arg, s_value);
        mpz_clear(s_value);
      }
      break;

    case 'b': ;
      uint64_t addr;
      char *file;

      if (!sscanf(optarg, "0x%" PRIx64 ",%ms", &addr, &file)) {
	fprintf(stderr, "Could not parse argument %s\n", optarg);
	return -1;
      };

      load_raw(addr, file);
      free(file);
      break;

    case 'i':
      load_image(optarg);
      break;

    case 'e':
      load_elf(optarg);
      break;

    case 'n':
      if (!sscanf(optarg, "0x%" PRIx64, &elf_entry)) {
	fprintf(stderr, "Could not parse address %s\n", optarg);
	return -1;
      }
      elf_entry_set = true;
      break;

    case 'l':
      if (!sscanf(optarg, "%" PRId64, &g_cycle_limit)) {
	fprintf(stderr, "Could not parse cycle limit %s\n", optarg);
	return -1;
      }
      break;

    default:
      fprintf(stderr, "Unrecognized option %s\n", optarg);
      return -1;
    }
  }

  // assignment to g_elf_entry is deferred until the end of file so that an
  // explicit command line flag will override the address read from the ELF
  // file.
  if (elf_entry_set) {
      g_elf_entry = elf_entry;
  }

  return 0;
}

/* ***** Setup and cleanup functions for RTS ***** */

void setup_rts(void)
{
  disable_tracing(UNIT);
  setup_library();
}

void cleanup_rts(void)
{
  cleanup_library();
  kill_mem();
}
