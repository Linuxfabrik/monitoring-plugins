#!/usr/bin/env bash

# This test does not cover:
# * acknowledgements via icinga2

logfile='/tmp/test_logfile'
cmd() {
    ./logfile3 --filename $logfile --critical-pattern 'error' --warning-pattern 'warn'; echo "retc=$?"
}

echo "Command: cmd"


rm -f /tmp/logfile.db

cat > $logfile << 'EOF'
test0
test1
warning
test2
test3
error
error
test4
EOF

echo "inode: $(ls -i $logfile)"

echo -e '\n\n1. run'
cmd

echo -e '\n\n2. run'
cmd

cat >> $logfile << 'EOF'
new test0
new test1
new warning
new test2
new test3
new error
new test4
EOF

echo -e '\n\n3. run'
cmd

echo -e '\n\n4. run'
cmd


# simulating copytruncate
cat > $logfile << 'EOF'
copytruncate test0
copytruncate warning
copytruncate test2
EOF

echo -e '\n\n5. run'
echo "inode: $(ls -i $logfile)"

cmd


# simulating rotation
rm $logfile
cat > $logfile << 'EOF'
rotation test0
rotation test1
rotation warning
rotation test2
rotation test3
rotation error
rotation error
rotation test4
EOF

echo -e '\n\n6. run'
echo "inode: $(ls -i $logfile)"

cmd


echo -e '\n\n7. run'
echo "inode: $(ls -i $logfile)"

cmd

