EXPECTED_FILE=$1
ACTUAL_FILE_NAME=$2
DEADLINE="2026-02-12 10:00:00 -0600"

while read -r WUSTL_KEY; do #redirection
    
    REPO="https://github.com/CSE2307SP26/${WUSTL_KEY}.git"
    
    
    git clone -q "$REPO" "$WUSTL_KEY" 2>/dev/null


    cd "$WUSTL_KEY" || continue

    #checkout cipher branch 
    git checkout -q cipher 2>/dev/null

    
    LAST=$(git rev-list -n 1 --before="$DEADLINE" cipher)

    if [ -z "$LAST" ]; then
        #student did not turn in commit before deadline 
        echo "${WUSTL_KEY}: 0"
        cd .. && rm -rf "$WUSTL_KEY"
        continue
    fi

    # Roll back the repository state to the last valid commit before deadline
    git checkout -q "$LAST" 2>/dev/null

    javac Cipher.java 
    if [ $? -eq 0 ]; then
        java Cipher > /dev/null 2>&1
            
        #check if the file exists 
        if [ -f "$ACTUAL_FILE_NAME" ]; then
            #diff expected vs actual 
            diff -q "$ACTUAL_FILE_NAME" "../$EXPECTED_FILE" > /dev/null
            if [ $? -eq 0 ]; then
                echo "${WUSTL_KEY}: 1"
            else
                echo "${WUSTL_KEY}: 0"
            fi
        else
            echo "${WUSTL_KEY}: 0" #file does not exist
        fi
    else
        echo "${WUSTL_KEY}: 0"
    fi

    cd ..
    rm -rf "$WUSTL_KEY"

done