#!/bin/bash -e

# defaults
JAR=""
JAR_OPTS=""
JAVA=java
LOG_FILE=""

# simple logger
function log() {
    if [ "$LOG_FILE" != "" ]; then
        echo "[`date -u +\"%Y-%m-%dT%H:%M:%SZ\"`] jrun.sh: $*" >> $LOG_FILE
    else
        echo "[`date -u +\"%Y-%m-%dT%H:%M:%SZ\"`] jrun.sh: $*" >&2
    fi
}

# process command line
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )
            echo "Usage: jrun.sh [OPTION]*"
            echo ""
            echo "Available Options:"
            echo " -h | --help               Show this Help"
            echo " -l | --log {_file_}       File to log to."
            echo " -c | --config-dir {_dir_} Directory to scan for *.jrun.sh files."
            echo " --java {_path_to_java}    Path to java executable (default: java)"
            echo " -j | --jar {_jar_file_}   Jar file to execute"
            echo ""
            echo "1: Scans _dir_ options and executes any *.jrun.sh files found therein."
            echo "2: Runs specified java executable, passing in any JAVA_OPT_ values"
            echo "   specified in the *.jrun.sh files, the _jar_file specified, and"
            echo "   any additional parameters from the command line."
            echo ""
            echo "License: MIT"
            echo ""
            echo "Project homepage: https://github.com/earlye/jrun"
            exit 0
            ;;
        -l | --log )
            shift
            LOG_FILE=$1
            shift
            ;;
        -c | --config-dir )
            shift
            log "config-dir: $1"
            if [ -d "$1" ] && [ "$(echo $1/*.jrun.sh)" != "" ]; then
                for f in $1/*.jrun.sh; do
                    log "config-file: $f"
                    . $f
                    # collapse all JAVA_OPT_ environment variable values into a single line:
                    JAVA_OPTS=$(export | grep JAVA_OPT_ | sed -e "s/.*=//g" -e "s/^\"//g;s/\"$//g" | tr '\r\n' ' ' | tr '\n' ' ')
                    log "JAVA_OPTS: ${JAVA_OPTS}"
                done
            fi
            shift
            ;;
        --java )
            shift
            JAVA=$1
            shift
            ;;
        -j | --jar )
            shift
            JAR=$1
            log "JAR: ${JAR}"
            shift
            ;;
        *)
            JAR_OPTS="$JAR_OPTS $1"
            log "JAR_OPTS: ${JAR_OPTS}"
            shift
            ;;
    esac
done

JAVA_CMD="${JAVA} ${JAVA_OPTS} -jar ${JAR} ${JAR_OPTS}"

log "Done processing command line arguments. Preparing to launch java"
log "JAVA_CMD: ${JAVA_CMD}"
${JAVA_CMD}
