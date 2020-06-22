#!/bin/sh
# run.sh [<runname>]
#
# Run benchmarks in ${BENCHMARKS} ${ITR} times each for ${DURATION} seconds.
#
# Benchmarks may specify an argument with the syntax <benchmark>:<arg>
#
# Output for each benchmark is in unixbench-<runname>-<benchmark>-<arg>.dat
# (unnecessicary -'s are removed).
#
# If statcounters support kcov, enable kernel coverage collection for each run
# by setting TRACE=kcov

ITR=10
DURATION=30
BENCHMARKS="syscall:execl syscall:getpid context1 pipe"
BENCHDIR=${BENCHDIR:-`pwd`/pgms}
OUTPUT_DIR=${OUTPUT_DIR:-`pwd`}
TRACE=${TRACE:-}

# Hack for exec benchmark
ln -sf /usr/bin/true /bin/true

export STATCOUNTERS_FORMAT=csv

if [ ! -d "${OUTPUT_DIR}" ]; then
    mkdir -p ${OUTPUT_DIR}
fi

for _bench in ${BENCHMARKS}; do
	prog=${_bench%%:*}
	arg=${_bench#*:}
	if [ "${arg}" == "${prog}" ]; then
		arg=
	fi
  log_pattern="unixbench${1:+-}${1}-${prog}${arg:+-}${arg}"
	log="${OUTPUT_DIR}/${log_pattern}.dat"
  stat_file="${OUTPUT_DIR}/${log_pattern}.stats"
  kcov_file="${OUTPUT_DIR}/${log_pattern}"
  rm -rf "$log"

	echo "priming $_bench"
  unset STATCOUNTERS_OUTPUT
  unset STATCOUNTERS_KCOV
	${BENCHDIR}/$prog 1 $arg > /dev/null 2>&1

  export STATCOUNTERS_OUTPUT=$stat_file
  if [ "$TRACE" = "kcov" ]; then
      export STATCOUNTERS_KCOV=yes
  fi
	for itr in `jot $ITR`; do
		  echo "$_bench $itr/$ITR"
      export STATCOUNTERS_KCOV_OUTPUT="${kcov_file}-run${itr}.kcov"
		  ${BENCHDIR}/$prog $DURATION $arg >> "$log" 2>&1
	done
done

echo "Clearing statcounters settings"
unset STATCOUNTERS_FORMAT
unset STATCOUNTERS_OUTPUT
unset STATCOUNTERS_KCOV
unset STATCOUNTERS_KCOV_OUTPUT
