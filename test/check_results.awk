#!/usr/bin/awk

BEGIN {
    # Set field separator
    FS = ","
    # Counters
    true_positive=0
    false_positive=0
    true_negative=0
    false_negative=0
}
{
    # Count results by type
    if($3 == 0){ #Negative
        if($4 == 0){ # True - Negative
            true_negative++
        }
        else { # False - Negative
            false_negative++
        }
    }
    else { #Positive
        if($4 == 1){ # True - Positive
            true_positive++
        }
        else { # False - Positive
            false_positive++
        }
    }
}
END {
    # Statistics
    total_true=true_positive+true_negative
    total_false=false_positive+false_negative
    positive_accuracy=true_positive/(true_positive+false_positive)*100
    negative_accuracy=true_negative/(true_negative+false_negative)*100
    total_accuracy=(true_positive+true_negative)*100/NR

    # Markdown file generation
    print "# Phishing Assassin" >> "/root/result.md"
    print "## Test Results" >> "/root/result.md"
    print "|  | Positive | Negative | Total |" >> "/root/result.md"
    print "| :--- | :---: | :---: | :---: |" >> "/root/result.md"
    print "| **True** |  " true_positive " |  " true_negative " | " total_true " |" >> "/root/result.md"
    print "| **False** | " false_positive "  | " false_negative " | " total_false " |" >> "/root/result.md"
    print "| **Accuracy** |  _" positive_accuracy "%_ |  _" negative_accuracy "%_ | _" total_accuracy "%_ |" >> "/root/result.md"
}