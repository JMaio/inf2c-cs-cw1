# find_word.c MIPS implementation
# separates words and returns to console
    # program variables
    .data
inmsg:      .asciiz "Enter input: "
outmsg:     .asciiz "output:\n"
nl:         .ascii  "\n"
nterm:      .ascii  "\0"
input_s:    .space  1001    # reserve segment 1000 bytes long for sentence
output_s:   .space  3001    # reserve segment for output pig latin
word:       .space  51      # reserve segment 50 bytes long for word
plw:        .space  53      # reserve segment 50 bytes long for plw
maxslen:    .word   1001    # store max sentence length
maxwlen:    .word   50      # store max word length
end:        .space  51      # store prefix to be put at end of plw
vowels:     .asciiz "AEIOUaeiou"

    # text segment
    .text

j_main:                     #### unconditional jump to main even if not set
    j main                  # to begin from main label

read_input:                 #### void read_input(const char* inp) {}
    li   $v0, 4             # print_string("\nEnter input: ");
    la   $a0, inmsg         #
    syscall                 #
                            #
    li   $v0, 8             # read_string(input_sentence, MAX_SENTENCE_LENGTH+1);
    la   $a0, input_s       # yield buffer address to $a0
    lw   $a1, maxslen       # yield max sentence length to $a1
    syscall                 #
                            #
    jr   $ra                # return to main

output:                     #### void output(const char* out) {}
    lb   $t0, nterm         # terminate word with null character
    sb   $t0, output_s($s4) #
    la   $a0, output_s      #
    li   $v0, 4             # void output(const char* out) {}
    syscall                 #
                            #
    j end_main              #

final_out:                  #### final_out deals with output of words before sentence null character, terminating the program immediately after
    la   $a0, nl            # print new line for new word
    li   $v0, 4             #
    syscall                 #
    lb   $t0, nterm         # terminate word with null character
    add  $s1, $s1, 1        #
    sb   $t0, word($s1)     #
                            #
    la   $a0, word          # load word into print argument
    li   $v0, 4             # void output(const char* out) {}
    syscall                 #
                            #
    j end_main              # terminate program

is_valid_char:              # ASCII: A: 65; Z: 90; a: 97; z: 122
    sle  $t0, $a0, 90       # if ( ch >= 'a' && ch <= 'z' )
    sge  $t1, $a0, 65       #
    and  $t0, $t0, $t1      # if between upper case A AND Z
    sle  $t1, $a0, 122      # else if ( ch >= 'A' && ch <= 'Z' )
    sge  $t2, $a0, 97       #
    and  $t1, $t1, $t2      # if between lower case a AND z
    or   $v0, $t0, $t1      # if in lower OR upper case
                            #
    jr   $ra                #

is_hyphen:                  # ASCII: -: 45
    seq  $v0, $a0, 45       # if ( ch == '-' )
    jr   $ra                # return true / false

is_nl_or_nterm:             #### checks end of sentence by newline or null character
    seq  $t0, $a0, 0        #
    seq  $t1, $a0, 10       #
    or   $v0, $t0, $t1      #
                            #
    jr   $ra                #

add_char:                   #### adds character to word
    add  $s1, $s1, 1        # char_index++;
    lw   $t1, maxwlen       #
                            #
    sb   $a0, word($s1)     # store char in word[i]
                            #
    j find_words            # character added successfully, return to main loop

    # main code block       # (below comment from hex.s)
    .globl main             # Declare main label to be globally visible.
                            # Needed for correct operation with MARS
main:
    li   $s0, 0             # load array index
    li   $s1, -1            # load word index
    jal read_input          # read_input(input_sentence)
                            #
    li   $v0, 4             # print_string("\noutput:\n");
    la   $a0, outmsg        #
    syscall                 #

find_words:                 #### main loop for input processing
    lw   $t0, maxslen       # load max sentence length into $t0
    bgt  $s0, $t0, end_main # force end on current index greater than allowed
                            #
    lb   $a0, input_s($s0)  # cur_char = inp[input_index];
    addi $s0, $s0, 1        # input_index++;
                            ## test character for validity
    jal is_valid_char       # is_valid_ch = is_valid_character(cur_char);
                            # if ( is_valid_ch ) {}
    beq  $v0, 1, add_char   # w[++char_index] = cur_char; else {
                            ## not valid character, check for end of sentence
    jal is_nl_or_nterm      # if ( cur_char == '\n' || cur_char == '\0' ) {
    move $s7, $v0           #
    beqz $v0, not_nl_or_nterm
    li   $a0, 0             #
    add  $s1, $s1, 1        # char_index++;
    sb   $a0, word($s1)     # store char in word[i]
    add  $s1, $s1, -1       # char_index--;
    not_nl_or_nterm:        #
    beq  $s7, 1, make_pig_latin
                            #     end_of_sentence = true; }
                            ## not end of sentence, check if hyphen followed by valid character
    sge  $s2, $s1, 0        # if ( char_index >= 0 )
                            #
    jal is_hyphen           #
    and  $s2, $s2, $v0      # && is_hyphen(cur_char)
                            #
    lb   $a0, input_s($s0)  # && is_valid_character(inp[input_index])
    jal is_valid_char       # check if character after current is valid
    and  $s2, $s2, $v0      # passed all checks -> $s2 == 1
                            #
    add  $t0, $s0, -1       ## if is hyphen followed by valid character, branch to add character
    lb   $a0, input_s($t0)  # && is_valid_character(inp[--input_index])
    beq  $s2, 1, add_char   # w[++char_index] = cur_char;
                            ## reaching this far means invalid character followed by invalid character
    bge  $s1, 0, make_pig_latin
                            #
    li   $s1, -1            # char_index = -1;
    sb   $a0, output_s($s4) # output_sentence[output_index]
    add  $s4, $s4, 1        # output_index++
                            # make pig latin if length > 0
    j find_words            # loop back and continue processing

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# register sequence:
# $s0 - current position in string
# $s1 - current word position / length / character index
# $s2 - character validity flag
# $s3 - pig-latined-word index
# $s4 - output_index
# $s5 - current vowel index
# $s6 - current word final index / length - 1
# $s7 - end of input sentence flag

is_upper:                   #
    sge  $t0, $a0, 65       # set if grater than A
    sle  $t1, $a0, 90       # set if less than Z
    and  $v0, $t0, $t1      #
    jr   $ra                #

is_lower:                   #
    sge  $t0, $a0, 97       # set if grater than a
    sle  $t1, $a0, 122      # set if less than z
    and  $v0, $t0, $t1      #
    jr   $ra                #

to_lower:                   #
    add  $v0, $a0, 32       #
    jr   $ra                #

to_upper:                   #
    sub  $v0, $a0, 32       #
    jr   $ra                #

is_vowel:                   #
    li   $v0, 0             #
    bge  $a2, 10, is_vowel_end # end if index greater than 10 (length of vowels string)
    lb   $a1, vowels($a2)   #
    addi $a2, $a2, 1        # increment index in vowels array
    seq  $v0, $a0, $a1      #
    beq  $v0, 1, is_vowel_end
                            #
    j is_vowel              #
                            #
    is_vowel_end:           #
    jr   $ra                #

make_pig_latin:             #
    lb   $a0, word          # stop if first char is not_valid
    jal is_valid_char       #
    beq  $v0, 0, output     # terminate word coming from find_words with nullchar
                            #
    add  $s1, $s1, 1        #
    sb   $a0, word($s1)     # store char in word[i]
    sub  $s6, $s1, 1        # $s6 = final index (length -1)
    li   $s1, 0             # general incrementer i / word index = 0
    li   $s3, 0             # plw index
    li   $s5, 0             # $s5 = vowel
    li   $t3, 0             #

    # $t1 - pre
    # $t2 - post
    # $t3 - capital
    # $t4 - vowel + pre
    # $t5 - pre + post

    # while (is_vowel(w[i]) == false && (i < len)) {
    make_end_array:         # take char from word until vowel found
    bgt  $s1, $s6, check_capital
    lb   $a0, word($s1)     # w[i]
    chk_vowel:              # check 1 character against all vowels
    li   $v0, 0             # assume not a vowel
    li   $a2, 0
    jal is_vowel            # check if vowel
    beq  $v0, 1, check_capital
    sb   $a0, end($s1)      # end[i] = w[i]
    add  $s1, $s1, 1        # i++
    j make_end_array        #
                            #
    # decide on capitalisation case
    check_capital:          #
    li   $a0, 0             #
    sb   $a0, end($s1)      # store null char in end
    lb   $a0, word          # w[0]
    jal is_upper            # if (is_upper(w[0])) {
    beqz $v0, no_caps       #
    add  $t3, $t3, $v0      # capital += is_upper(w[0])
    lb   $a0, word($s6)     # w[l]
    jal is_lower            # if (is_lower(w[1])
    add  $t3, $t3, $v0      # capital += is_lower(w[len-1])
                            #
    no_caps:                #
    # while (pre < (len-vowel)) {
    move $s5, $s1           # vowel = i;
    sub  $t6, $s6, $s5      # $t5 = len-vowel
    li   $t1, 0             # $t1 - pre
    li   $t2, 0             # $t2 - post
                            #
    make_pre_plw:           #
    add  $t4, $s5, $t1      # vowel+pre;
    bgt  $t1, $t6, make_post_plw # pre >= len - vowel
    lb   $t0, word($t4)     # w[vowel+pre]
    sb   $t0, plw($t1)      # plw[pre] = w[vowel+pre]
    add  $t1, $t1, 1        # pre++
    add  $s3, $s3, 1        # plw++
    j make_pre_plw          #
                            #
    # while (post < vowel) {#
    make_post_plw:          #
    bge  $t2, $s5, capital  # post >= vowel
    lb   $t0, end($t2)      # end[post]
    add  $t5, $t1, $t2      # pre+post
    sb   $t0, plw($t5)      # plw[pre+post] = end[post];
    add  $t2, $t2, 1        # post++;
    add  $s3, $s3, 1        # plw++
    j make_post_plw         #
                            #
    capital:                #
    beq  $t3, 0, add_ay_locase
    beq  $t3, 1, add_ay_upcase
    capital2:               # if (capital == 2)
    lb   $a0, word          # w[0]
    li   $v0, 0             # assume not a vowel
    li   $a2, 0             #
    jal is_vowel            # is_vowel(w[0])
    beq  $v0, 1, add_ay_locase # if (!is_vowel(w[0]))
                            #
    lb   $a0, plw           # plw[0] ( == w[vowel])
    jal to_upper            # to_upper(plw[0]);
    sb   $v0, plw           # plw[0] = to_upper(plw[0]);
                            #
    lb   $a0, plw($t1)      # plw[pre] ( == w[0])
    jal to_lower            # to_lower(plw[pre]);
    sb   $v0, plw($t1)      # plw[pre] = to_lower(plw[pre]);
                            #
    add_ay_locase:          #
    li   $t0, 'a'           #
    sb   $t0, plw($s3)      #
    add  $s3, $s3, 1        #
    li   $t0, 'y'           #
    sb   $t0, plw($s3)      #
    add  $s3, $s3, 1        #
    j plw_to_output         #
                            #
    add_ay_upcase:          #
    li   $t0, 'A'           #
    sb   $t0, plw($s3)      #
    add  $s3, $s3, 1        #
    li   $t0, 'Y'           #
    sb   $t0, plw($s3)      #
    add  $s3, $s3, 1        #
                            #
    plw_to_output:          #
    li   $s1, 0             #
    add  $s6, $s6, 2        #
    output_loop:            #
    bge  $s1, $s3, output_done
    lb   $t0, plw($s1)      # plw[i++]
    add  $s1, $s1, 1        # i++
    sb   $t0, output_s($s4) # output_sentence[output_index++] = plw[i++]
    add  $s4, $s4, 1        # output_index++
    j output_loop           #
                            #
    output_done:            #
    sub  $t0, $s0, 1        #
    lb   $t0, input_s($t0)  # cur_char = inp[input_index];
    sb   $t0, output_s($s4) # output_sentence[output_index++] = plw[i++]
    add  $s4, $s4, 1        # output_index++
    li   $s1, -1            # char_index = -1;
    bne  $s7, 1, find_words #
    j output                #

end_main:                   #
    li   $v0, 10            # exit()
    syscall                 #
