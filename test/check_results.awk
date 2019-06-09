#!/usr/bin/awk

BEGIN {
    # Set field separator
    FS = ","
    # Counters
    true_positive=0
    false_positive=0
    true_negative=0
    false_negative=0
    nphishing=0
    nleg=0
    }
NR != 1 { # Skip csv header file
    # Count results by type
    if($3 == 0){ #Negative
        if($4 == 0){ # True - Negative
            true_negative++
            nleg++
        }
        else { # False - Negative
            false_negative++
            nphishing++
        }
    }
    else { #Positive
        if($4 == 1){ # True - Positive
            true_positive++
            nphishing++
        }
        else { # False - Positive
            false_positive++
            nleg++
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
    hitrate=1-(false_negative/nphishing)
    strikerate=false_positive/nleg
    precision=(nphishing-false_negative)/(nphishing-false_negative+false_positive)
    recall=(nphishing-false_negative)/(nphishing)
    fscore = (2*precision*recall)/(precision+recall)
    tcr_mark = (nphishing)/(1*false_positive+false_negative)
    tcr_classify = (nphishing)/(9*false_positive+false_negative)
    tcr_delete = (nphishing)/(999*false_positive+false_negative)

    # Markdown file generation
    print "# Phishing Assassin" >> "/root/result.md"
    print "## Test Results" >> "/root/result.md"
    print "### Confusion Matrix" >> "/root/result.md"
    print "|  | Positive | Negative | Total |" >> "/root/result.md"
    print "| :--- | :---: | :---: | :---: |" >> "/root/result.md"
    print "| **True** |  " true_positive " |  " true_negative " | " total_true " |" >> "/root/result.md"
    print "| **False** | " false_positive "  | " false_negative " | " total_false " |" >> "/root/result.md"
    print "| **Accuracy** |  _" positive_accuracy "%_ |  _" negative_accuracy "%_ | _" total_accuracy "%_ |" >> "/root/result.md"
    print "### Batting Average" >> "/root/result.md"
    print "- _BA<hitrate,strikerate>_ = <" hitrate ", " strikerate ">" >> "/root/result.md"
    print "### Precision" >> "/root/result.md"
    print "- _precision_ = " precision >> "/root/result.md"
    print "### Recall" >> "/root/result.md"
    print "- _recall_ = " recall >> "/root/result.md"
    print "### f-score" >> "/root/result.md"
    print "- _f-score_ = " fscore >> "/root/result.md"
    print "### Total Cost Ratio" >> "/root/result.md"
    print "- (Mark)     _TCR_ = " tcr_mark >> "/root/result.md"
    print "- (Classify) _TCR_ = " tcr_classify >> "/root/result.md"
    print "- (Delete)   _TCR_ = " tcr_delete >> "/root/result.md"
}