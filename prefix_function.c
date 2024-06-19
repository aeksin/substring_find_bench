extern int prefix_function_asm2(const char *str, long long * res_len, long long * str_len, long long * pi);
long long  prefix_function_c(const char * str, long long res_len, long long str_len, long long * pi){
    for (long long i=1;i<str_len;i++){
        long long c = pi[i-1];
        while (c>0 && str[i]!= str[c]){
            c = pi[c-1];
        }
        if (str[i] == str[c]){
            pi[i] = c + 1;
        }
    }
    int j=0;
    for (long long i=0;i<str_len;i++){
       if (pi[i] == res_len){
           pi[j] = i-2*res_len;
           j++;
       }
    }
    return j;
}
long long  prefix_function_c_preprocess(const char * substring, long long res_len, long long str_len, long long * pi){
    for (long long i=1;i<res_len;i++){
        long long c = pi[i-1];
        while (c>0 && substring[i]!= substring[c]){
            c = pi[c-1];
        }
        if (substring[i] == substring[c]){
            pi[i] = c + 1;
        }
    }
    return 0;
}
long long  prefix_function_c_postprocess(const char * string, long long res_len, long long str_len, long long * pi, const char * substring){
    for (long long i=res_len+1, j=0; j<str_len;i++, j++){
        long long c = pi[i-1];
        while ((c == res_len) || (c>0 && string[j]!= substring[c])){
            c = pi[c-1];
        }
        if (string[j] == substring[c]){
            pi[i] = c + 1;
        }
    }
    int j=0;
    for (long long i=res_len;i<str_len+res_len+1;i++){
       if (pi[i] == res_len){
           pi[j] = i-2*res_len;
           j++;
       }
    }
    return j;
}

long long prefix_function_asm(const char * str, long long res_len, long long str_len, long long * pi){
    long long pos  = prefix_function_asm2(str, &res_len, &str_len, pi);
    return pos;
}
long long prefix_function_asm_fast(const char * string, long long res_len, long long str_len, long long * pi, const char * substring){
    prefix_function_asm_fast_prep(substring, &res_len, &str_len, pi);
    long long pos = prefix_function_asm_fast_post(string, &res_len, &str_len, pi, substring);
    return pos;
}