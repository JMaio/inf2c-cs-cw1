// ==========================================================================
// PigLatin Converter
// ==========================================================================
// Convert all words in a sentence using PigLatin rules

// Inf2C-CS Coursework 1. Task B
// PROVIDED file, to be used to complete the task in C and as a model for writing MIPS code.

// Instructor: Boris Grot
// TA: Priyank Faldu
// 10 Oct 2017

//---------------------------------------------------------------------------
// C definitions for SPIM system calls
//---------------------------------------------------------------------------
#include <stdio.h>

void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(char c)    { printf("%c", c); }
void print_int(int num)    { printf("%d", num); }
void print_string(const char* s) { printf("%s", s); }

#define false 0
#define true 1

// Maximum characters in an input sentence excluding terminating null character
#define MAX_SENTENCE_LENGTH 1000

// Maximum characters in a word excluding terminating null character
#define MAX_WORD_LENGTH 50

// Global variables
// +1 to store terminating null character
char input_sentence[MAX_SENTENCE_LENGTH+1];
char output_sentence[(MAX_SENTENCE_LENGTH*3)+1];

void read_input(const char* inp) {
    print_string("Enter input: ");
    read_string(input_sentence, MAX_SENTENCE_LENGTH+1);
}

void output(const char* out) {
    print_string(out);
    print_string("\n");
}

// Do not modify anything above
//
//
// Define your global variables here
//
// Maximum characters in an input sentence excluding terminating null character
#define MAX_SENTENCE_LENGTH 1000
// Maximum characters in a word excluding terminating null character
#define MAX_WORD_LENGTH 50
//
// Write your own functions here
//
//
int input_index = 0;
int output_index = 0;
int char_index = -1;
int end_of_sentence = false;

char input_sentence[MAX_SENTENCE_LENGTH+1]; // basically it's a list of characters, aka a string!
char word[MAX_WORD_LENGTH+1];
char plw[MAX_WORD_LENGTH+1];

int is_vowel(char c) {
    return (c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U' ||
            c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u')
        ? true : false;
}

int is_upper(char c) {
    return (c >= 'A' && c <= 'Z') ? true : false;
}

int is_lower(char c) {
    return (c >= 'a' && c <= 'z') ? true : false;
}

char to_lower(char c) {
    return (char) ((int) c + 32);
}

char to_upper(char c) {
    return (char) ((int) c - 32);
}

int length(char* w) {
    int l = 0;
    while (w[l] != '\0') {
        l++;
    }
    return l;
}

// returns true only if an input character is hyphen
int is_hyphen(char ch) {
    return ( ch == '-' ) ? true : false;
}

void make_pig_latin(char* w, char* plw) {
    // "hello"
    // work up to first vowel - w[1] -> v
    // add characters from w[v..l] to new[0..v]
    // add characters from end[0..v] to new[v..l]
    int len = length(w);                // string length
    int i = 0;                          // general incrementer - $s1
    int vowel = 0;                      // index of first vowel

    int pre = 0;                        // increments from 0 to
    int post = 0;                       // increments from 0 to v
    int capital = 0;

    char end[MAX_WORD_LENGTH+1];

    while (is_vowel(w[i]) == false && (i < len)) {
        end[i] = w[i];                  // append character to "end" until vowel is found or word ends
        i++;
    }

    vowel = i;

    if (is_upper(w[0])) {
        capital++;
        if (is_lower(w[len-1])) {
            capital++;
        }
    }

    while (pre < (len-vowel)) {         // add remaining to initial of plw
        plw[pre] = w[vowel+pre];        // ello -> plw
        pre++;
    }

    while (post < vowel) {              // for initially removed characters
        plw[pre+post] = end[post];
        post++;
    }

    if (capital == 2) {                 // capital2
        if (!is_vowel(w[0])) {
            plw[0] = to_upper(w[vowel]);
            plw[pre] = to_lower(w[0]);
        }
    }

    if (capital == 1) {
        plw[pre+(post++)] = 'A';
        plw[pre+(post++)] = 'Y';
    } else {
        plw[pre+(post++)] = 'a';
        plw[pre+(post++)] = 'y';
    }

    plw[pre+post] = '\0';
}

// returns true if an input character is a valid word character
// returns false if an input character is any punctuation mark (including hyphen)
int is_valid_character(char ch) {
    if ( ch >= 'a' && ch <= 'z' ) {
        return true;
    } else return ( ch >= 'A' && ch <= 'Z' ) ? true : false;
}



int find_words(char* inp, char* w) {
    // following lines re-used from original program
    char cur_char = '\0';
    int is_valid_ch = false;

    // Indicates how many elements in "w" contains valid word characters
    int char_index = -1;

    while( end_of_sentence == false ) {
        // This loop runs until end of an input sentence is encountered or a valid word is extracted
        cur_char = inp[input_index];
        input_index++;

        // Check if it is a valid character
        is_valid_ch = is_valid_character(cur_char);

        if ( is_valid_ch ) {
            w[++char_index] = cur_char;
        } else {
            if ( cur_char == '\n' || cur_char == '\0' ) {
                // Indicates an end of an input sentence
                end_of_sentence = true;
            }
            if ( char_index >= 0 ) {
                // w has accumulated some valid characters. Thus, punctuation mark indicates a possible end of a word
                if ( is_hyphen(cur_char) == true && is_valid_character(inp[input_index]) ) {
                    // check if the next character is also a valid character to detect hyphenated word.
                    w[++char_index] = cur_char;
                    continue;
                }
                // w has accumulated some valid characters. Thus, punctuation mark indicates an end of a word
                char_index++;
                w[char_index] = '\0';
                return true;
            }
            // skip the punctuation mark
            w[0] = '\0';
            char_index = -1;
            if (cur_char != '\n') {
                output_sentence[output_index++] = cur_char;
            }
        }
    }
    return false;
}

void process_input(char* inp, char* out) {
    // thought process
    // sentence input - only replace valid words with PigLatin'ed words
        // - check valid words - convert these
        // - re-use output function - instead of outputting, pass to make_pig_latin
            // - then output result
        // else, output any and all invalid characters

    int word_found = false;

    do {
        word_found = find_words(input_sentence, word);
        if ( word_found == true ) {
            make_pig_latin(word, plw);
            // print_string(plw);
            int i = 0;
            while (i < length(plw)) {
                output_sentence[output_index++] = plw[i++];
            }
        }
        output_sentence[output_index++] = input_sentence[input_index-1];

    } while ( word_found == true );

}
//
// Do not modify anything below



int main() {

    read_input(input_sentence);

    print_string("\noutput:\n");

    output_sentence[0] = '\0';
    process_input(input_sentence, output_sentence);

    output(output_sentence);

    return 0;
}

//---------------------------------------------------------------------------
// End of file
//---------------------------------------------------------------------------
