import ctypes
import re
from timeit import default_timer as timer

libasm = ctypes.CDLL("./libasm.so")
string = "ra" * 1000000 + "rcx" * 2000000 + "rda" * 1000000
string = string * 60
target_substring = "rcx" * 2000000


def measure_time(function):
    def wrapper(*args, **kwargs):
        start_time = timer()
        res = function(*args, **kwargs)
        end_time = timer()
        time = end_time - start_time
        print(f"function {function.__name__} executed in {time} seconds")
        return res

    return wrapper


@measure_time
def prefix_function(string: str, substring: str) -> list:
    merged_string = substring + "#" + string
    string_len = len(merged_string)
    substring_len = len(substring)
    prefix = [0] * string_len
    res = list()
    for i in range(1, string_len):
        current_prefix = prefix[i - 1]
        while current_prefix > 0 and merged_string[i] != merged_string[current_prefix]:
            current_prefix = prefix[current_prefix - 1]
        if merged_string[i] == merged_string[current_prefix]:
            current_prefix += 1
        prefix[i] = current_prefix
        if prefix[i] == substring_len:
            res.append(i - 2 * substring_len)
    return res


@measure_time
def find_all_substrings_py(string, substring):
    indices = []
    while string.find(substring) != -1:
        idx = string.find(substring)
        if len(indices) != 0:
            indices.append(indices[-1] + idx + 1)
        else:
            indices.append(idx)
        string = string[idx + 1 :]
    return indices


@measure_time
def find_all_substrings_regex(string, substring):
    res = [m.start() for m in re.finditer(substring, string)]
    return res


@measure_time
def find_all_substrings_c(string, substring):
    merged_string = substring + "#" + string
    libasm.prefix_function_c.argtypes = [
        ctypes.c_char_p,
        ctypes.c_longlong,
        ctypes.c_longlong,
        ctypes.POINTER(ctypes.c_longlong),
    ]
    libasm.prefix_function_c.restype = ctypes.c_longlong
    indices = (ctypes.c_longlong * len(merged_string))()
    b_merged_string = merged_string.encode("utf-8")
    indices_size = libasm.prefix_function_c(
        b_merged_string, len(substring), len(merged_string), indices
    )
    return indices[:indices_size]


@measure_time
def find_all_substrings_c_faster(string, substring):
    indices = (ctypes.c_longlong * (len(string) + len(substring)))()
    b_string = string.encode("utf-8")
    b_substring = substring.encode("utf-8")
    libasm.prefix_function_c_preprocess.argtypes = [
        ctypes.c_char_p,
        ctypes.c_longlong,
        ctypes.c_longlong,
        ctypes.POINTER(ctypes.c_longlong),
    ]
    libasm.prefix_function_c_preprocess.restype = ctypes.c_longlong
    libasm.prefix_function_c_postprocess.argtypes = [
        ctypes.c_char_p,
        ctypes.c_longlong,
        ctypes.c_longlong,
        ctypes.POINTER(ctypes.c_longlong),
        ctypes.c_char_p,
    ]
    libasm.prefix_function_c_postprocess.restype = ctypes.c_longlong
    libasm.prefix_function_c_preprocess(
        b_string, len(substring), len(string), indices, b_substring
    )
    indices_size = libasm.prefix_function_c_postprocess(
        b_string, len(substring), len(string), indices, b_substring
    )
    return indices[:indices_size]


@measure_time
def find_all_substrings_asm(string, substring):
    merged_string = substring + "#" + string
    libasm.prefix_function_asm.argtypes = [
        ctypes.c_char_p,
        ctypes.c_longlong,
        ctypes.c_longlong,
        ctypes.POINTER(ctypes.c_longlong),
    ]
    libasm.prefix_function_asm.restype = ctypes.c_longlong
    indices = (ctypes.c_longlong * len(merged_string))()
    b_merged_string = merged_string.encode("utf-8")
    indices_size = libasm.prefix_function_asm(
        b_merged_string, len(substring), len(merged_string), indices
    )
    return indices[:indices_size]


@measure_time
def find_all_substrings_asm_faster(string, substring):
    indices = (ctypes.c_longlong * (len(string) + len(substring)))()
    b_string = string.encode("utf-8")
    b_substring = substring.encode("utf-8")
    libasm.prefix_function_asm_fast.argtypes = [
        ctypes.c_char_p,
        ctypes.c_longlong,
        ctypes.c_longlong,
        ctypes.POINTER(ctypes.c_longlong),
        ctypes.c_char_p,
    ]
    libasm.prefix_function_asm_fast.restype = ctypes.c_longlong
    indices_size = libasm.prefix_function_asm_fast(
        b_string, len(substring), len(string), indices, b_substring
    )
    return indices[:indices_size]


result_list = list()
result_list.append(prefix_function(string, target_substring))
result_list.append(find_all_substrings_py(string, target_substring))
result_list.append(find_all_substrings_regex(string, target_substring))
result_list.append(find_all_substrings_c(string, target_substring))
result_list.append(find_all_substrings_c_faster(string, target_substring))
result_list.append(find_all_substrings_asm(string, target_substring))
result_list.append(find_all_substrings_asm_faster(string, target_substring))
assert len(set(tuple(x) for x in result_list)) == 1
