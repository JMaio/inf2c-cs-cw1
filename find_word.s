# find_word.c MIPS implementation
# separates words and returns to console
    # program variables
    .data
inmsg:      .asciiz "Enter input: "
outmsg:     .asciiz "output:"
nl:         .ascii  "\n"
nterm:      .ascii  "\0"
buffer:     .space  1001    # reserve segment 1000 bytes long for sentence
word:       .space  51      # reserve segment 50 bytes long for word
maxslen:    .word   1001    # store max sentence length
maxwlen:    .word   50      # store max word length

# register sequence:
# $s0 - current position in string
# $s1 - current word position / length / character index
# $s2 - character validity flag

    # text segment
    .text

jump_main:                  #### unconditional jump to main even if not set
    j main                  # to begin from main label

read_input:                 #### void read_input(const char* inp) {}
    li   $v0, 4             # print_string("\nEnter input: ");
    la   $a0, inmsg         #
    syscall                 #
                            #
    li   $v0, 8             # read_string(input_sentence, MAX_SENTENCE_LENGTH+1);
    la   $a0, buffer        # yield buffer address to $a0
    lw   $a1, maxslen       # yield max sentence length to $a1
    syscall                 #
                            #
    jr   $ra                # return to main

output:                     #### void output(const char* out) {}
    la   $a0, nl            # print new line for new word
    li   $v0, 4             #
    syscall                 #
                            #
    lb   $t0, nterm         # terminate word with null character
    sb   $t0, word+1($s1)   #
                            #
    li   $s1, -1            # reset word length counter
    la   $a0, word          # load word into print argument
    li   $v0, 4             # void output(const char* out) {}
    syscall                 #
                            #
    j process_input         # word output, return to processing input

final_out:                  #### final_out deals with output of words before sentence null character, terminating the program immediately after
    blt  $s1, 0, end        #
    la   $a0, nl            # print new line for new word
    li   $v0, 4             #
    syscall                 #
    lb   $t0, nterm         # terminate word with null character
    sb   $t0, word+1($s1)   #
                            #
    la   $a0, word          # load word into print argument
    li   $v0, 4             # void output(const char* out) {}
    syscall                 #
                            #
    j end                   # terminate program

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
    bgt  $s1, $t1, output   # max word length exceeded, output
                            #
    sb   $a0, word($s1)     # store char in word[i]
                            #
    j process_input         # character added successfully, return to main loop

    # main code block       # (below comment from hex.s)
    .globl main             # Declare main label to be globally visible.
                            # Needed for correct operation with MARS
main:
    li   $s0, 0             # load array index
    li   $s1, -1            # load word index
                            #
    jal read_input          # read_input(input_sentence)
                            #
    li   $v0, 4             # print_string("\noutput:\n");
    la   $a0, outmsg        #
    syscall                 #

process_input:              #### main loop for input processing
                            ## load current character into register
    lw   $t0, maxslen       # load max sentence length into $t0
    bgt  $s0, $t0, end      # force end on current index greater than allowed
                            #
    lb   $a0, buffer($s0)   # cur_char = inp[input_index];
    addi $s0, $s0, 1        # input_index++;
                            ## test character for validity
    jal is_valid_char       # is_valid_ch = is_valid_character(cur_char);
                            # if ( is_valid_ch ) {}
    beq  $v0, 1, add_char   # w[++char_index] = cur_char; else {
                            ## not valid character, check for end of sentence
    jal is_nl_or_nterm      # if ( cur_char == '\n' || cur_char == '\0' ) {
    beq  $v0, 1, final_out  #     end_of_sentence = true; }
                            ## not end of sentence, check if hyphen followed by valid character
    sge  $s2, $s1, 0        # if ( char_index >= 0 )
                            #
    jal is_hyphen           #
    and  $s2, $s2, $v0      # && is_hyphen(cur_char)
                            #
    lb   $a0, buffer($s0)   # && is_valid_character(inp[input_index])
    jal is_valid_char       # check if character after current is valid
    and  $s2, $s2, $v0      # passed all checks -> $s2 == 1
                            #
    add  $t0, $s0, -1       ## if is hyphen followed by valid character, branch to add character
    lb   $a0, buffer($t0)   # && is_valid_character(inp[--input_index])
    beq  $s2, 1, add_char   # w[++char_index] = cur_char;
                            ## reaching this far means invalid character followed by invalid character
    bge  $s1, 0, output     # output word if length > 0
    j process_input         # loop back and continue processing

end:                        #
    li   $v0, 10            # exit()
    syscall                 #
