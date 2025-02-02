#!/bin/bash

SRCDIR=./src/
NUL=/dev/null
PASS=0
FAIL=0
clear
printf "Preparing a test environment...\n"
printf "   * Starting a fresh regtest daemon\n"
rm -r ~/.bitcoin/regtest
$SRCDIR/tokencored --regtest --server --daemon --tokenactivationallowsender=any --tokendebug=verbose >$NUL
sleep 10
printf "   * Preparing some mature testnet RPD\n"
$SRCDIR/tokencore-cli --regtest generate 105 >$NUL
printf "   * Obtaining addresses to work with\n"
ADDR=$($SRCDIR/tokencore-cli --regtest getnewaddress TOKENAccount)
FADDR=$($SRCDIR/tokencore-cli --regtest getnewaddress)
printf "   * Master address is %s\n" $ADDR
printf "   * Funding the addresses with some testnet RPD for fees\n"
JSON="{\""$ADDR"\":5,\""$FADDR"\":4}"
$SRCDIR/tokencore-cli --regtest sendmany "" $JSON >$NUL
$SRCDIR/tokencore-cli --regtest sendtoaddress $ADDR 6 >$NUL
$SRCDIR/tokencore-cli --regtest sendtoaddress $ADDR 7 >$NUL
$SRCDIR/tokencore-cli --regtest sendtoaddress $ADDR 8 >$NUL
$SRCDIR/tokencore-cli --regtest sendtoaddress $ADDR 9 >$NUL
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "   * Creating a test (managed) property and granting 1000 tokens to the test address\n"
$SRCDIR/tokencore-cli --regtest token_sendissuancemanaged $ADDR 1 1 0 "TestCat" "TestSubCat" "TestProperty" "TestURL" "TestData" >$NUL
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
$SRCDIR/tokencore-cli --regtest sendtokengrant $ADDR $FADDR 3 1000 >$NUL
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "\nRunning the test scenario...\n"
printf "   * Sending a 'freeze' tranasction for the test address prior to enabling freezing\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was INVALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "false," ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking that freezing is currently disabled... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "false," ]
  then
    printf "                                      PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                      FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'enable freezing' transaction to ENABLE freezing\n"
TXID=$($SRCDIR/tokencore-cli --regtest sendtokenenablefreezing $ADDR 3)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'enable freezing' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                              PASS\n"
    PASS=$((PASS+1))
  else
    printf "                              FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking that freezing is now enabled... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "true," ]
  then
    printf "                                             PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                             FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending another 'freeze' tranasction for the test address\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was now VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                   PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                   FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Testing a send from the test address (should now be frozen)\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_send $FADDR $ADDR 3 50)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'send' transaction was INVALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "false," ]
  then
    printf "                                       PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                       FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking the test address balance has not changed... "
BALANCE=$($SRCDIR/tokencore-cli --regtest token_getbalance $FADDR 3 | grep balance | cut -d '"' -f4)
if [ $BALANCE == "1000" ]
  then
    printf "                                 PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                 FAIL (result:%s)\n" $BALANCE
    FAIL=$((FAIL+1))
fi
printf "   * Sending an 'unfreeze' tranasction for the test address\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendunfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'unfreeze' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Testing a send from the test address (should now be unfrozen)\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_send $FADDR $ADDR 3 50)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'send' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                         PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                         FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking the test address balance has reduced by the amount of the send... "
BALANCE=$($SRCDIR/tokencore-cli --regtest token_getbalance $FADDR 3 | grep balance | cut -d '"' -f4)
if [ $BALANCE == "950" ]
  then
    printf "           PASS\n"
    PASS=$((PASS+1))
  else
    printf "           FAIL (result:%s)\n" $BALANCE
    FAIL=$((FAIL+1))
fi
printf "   * Sending another 'freeze' tranasction for the test address\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was now VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                   PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                   FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'disable freezing' transaction to DISABLE freezing\n"
TXID=$($SRCDIR/tokencore-cli --regtest sendtokendisablefreezing $ADDR 3)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'disable freezing' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                             PASS\n"
    PASS=$((PASS+1))
  else
    printf "                             FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking that freezing is now disabled... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "false," ]
  then
    printf "                                            PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                            FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Testing a send from the test address (unfrozen when freezing was disabled)\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_send $FADDR $ADDR 3 30)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'send' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                         PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                         FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking the test address balance has reduced by the amount of the send... "
BALANCE=$($SRCDIR/tokencore-cli --regtest token_getbalance $FADDR 3 | grep balance | cut -d '"' -f4)
if [ $BALANCE == "920" ]
  then
    printf "           PASS\n"
    PASS=$((PASS+1))
  else
    printf "           FAIL (result:%s)\n" $BALANCE
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'freeze' tranasction for the test address to test that freezing is now disabled\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was INVALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "false," ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a feature 14 activation to activate the notice period\n"
BLOCKS=$($SRCDIR/tokencore-cli --regtest getblockcount)
TXID=$($SRCDIR/tokencore-cli --regtest token_sendactivation $ADDR 14 $(($BLOCKS + 8)) 999)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the activation transaction was valid... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Mining 10 blocks to forward past the activation block\n"
$SRCDIR/tokencore-cli --regtest generate 10 >$NUL
printf "        - Checking the activation went live as expected... "
FEATUREID=$($SRCDIR/tokencore-cli --regtest token_getactivations | grep -A 10 completed | grep featureid | cut -c20-21)
if [ $FEATUREID == "14" ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $FEATUREID
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'enable freezing' transaction to ENABLE freezing\n"
TXID=$($SRCDIR/tokencore-cli --regtest sendtokenenablefreezing $ADDR 3)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'enable freezing' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                              PASS\n"
    PASS=$((PASS+1))
  else
    printf "                              FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking that freezing is still disabled (due to wait period)... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "false," ]
  then
    printf "                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'freeze' tranasction for the test address before waiting period expiry\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was INVALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "false," ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Mining 30 blocks to forward past the waiting period\n"
$SRCDIR/tokencore-cli --regtest generate 10 >$NUL
printf "        - Checking that freezing is now enabled... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "true," ]
  then
    printf "                                             PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                             FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'freeze' tranasction for the test address after waiting period expiry\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                       PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                       FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Testing a Send All from the test address (now frozen))\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendall $FADDR $ADDR 1)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'Send All' transaction was INVALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "false," ]
  then
    printf "                                   PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                   FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking the test address balance has not changed... "
BALANCE=$($SRCDIR/tokencore-cli --regtest token_getbalance $FADDR 3 | grep balance | cut -d '"' -f4)
if [ $BALANCE == "920" ]
  then
    printf "                                 PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                 FAIL (result:%s)\n" $BALANCE
    FAIL=$((FAIL+1))
fi
printf "   * Sending an 'unfreeze' tranasction for the test address\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendunfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'unfreeze' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "\nRunning reorg test scenarios\n"
printf "   * Rolling back the chain to test reversing the last UNFREEZE tx\n"
BLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
BLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
$SRCDIR/tokencore-cli --regtest invalidateblock $BLOCKHASH >$NUL
PREVBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
$SRCDIR/tokencore-cli --regtest clearmempool >$NUL
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
NEWBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
NEWBLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
printf "        - Checking the block count is the same as before the rollback...                        "
if [ $BLOCK == $NEWBLOCK ]
  then
    printf "PASS\n"
    PASS=$((PASS+1))
  else
    printf "FAIL (result:%s)\n" $NEWBLOCK
    FAIL=$((FAIL+1))
fi
printf "        - Checking the block hash is different from before the rollback...                      "
if [ $BLOCKHASH == $NEWBLOCKHASH ]
  then
    printf "FAIL (result:%s)\n" $NEWBLOCKHASH
    FAIL=$((FAIL+1))
  else
    printf "PASS\n"
    PASS=$((PASS+1))
fi
printf "   * Testing a send from the test address (should now be frozen again as the block that unfroze the address was dc'd)\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_send $FADDR $ADDR 3 30)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'send' transaction was INVALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "false," ]
  then
    printf "                                       PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                       FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending an 'unfreeze' tranasction for the test address\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendunfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'unfreeze' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                     PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                     FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
$SRCDIR/tokencore-cli --regtest generate 3 >$NUL
printf "   * Sending an 'freeze' tranasction for the test address\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                       PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                       FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Rolling back the chain to test reversing the last FREEZE tx\n"
BLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
BLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
$SRCDIR/tokencore-cli --regtest invalidateblock $BLOCKHASH >$NUL
PREVBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
$SRCDIR/tokencore-cli --regtest clearmempool >$NUL
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
NEWBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
NEWBLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
printf "        - Checking the block count is the same as before the rollback...                        "
if [ $BLOCK == $NEWBLOCK ]
  then
    printf "PASS\n"
    PASS=$((PASS+1))
  else
    printf "FAIL (result:%s)\n" $NEWBLOCK
    FAIL=$((FAIL+1))
fi
printf "        - Checking the block hash is different from before the rollback...                      "
if [ $BLOCKHASH == $NEWBLOCKHASH ]
  then
    printf "FAIL (result:%s)\n" $NEWBLOCKHASH
    FAIL=$((FAIL+1))
  else
    printf "PASS\n"
    PASS=$((PASS+1))
fi
printf "   * Testing a send from the test address (should now be unfrozen again as the block that froze the address was dc'd)\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_send $FADDR $ADDR 3 30)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'send' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                         PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                         FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'freeze' tranasction for the test address\n"
TXID=$($SRCDIR/tokencore-cli --regtest token_sendfreeze $ADDR $FADDR 3 1234)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'freeze' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                                       PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                       FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'disable freezing' transaction to DISABLE freezing\n"
TXID=$($SRCDIR/tokencore-cli --regtest sendtokendisablefreezing $ADDR 3)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'disable freezing' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                             PASS\n"
    PASS=$((PASS+1))
  else
    printf "                             FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking that freezing is now disabled... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "false," ]
  then
    printf "                                            PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                            FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Rolling back the chain to test reversing the last DISABLE FREEZEING tx\n"
BLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
BLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
$SRCDIR/tokencore-cli --regtest invalidateblock $BLOCKHASH >$NUL
PREVBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
$SRCDIR/tokencore-cli --regtest clearmempool >$NUL
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
NEWBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
NEWBLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
printf "        - Checking the block count is the same as before the rollback...                        "
if [ $BLOCK == $NEWBLOCK ]
  then
    printf "PASS\n"
    PASS=$((PASS+1))
  else
    printf "FAIL (result:%s)\n" $NEWBLOCK
    FAIL=$((FAIL+1))
fi
printf "        - Checking the block hash is different from before the rollback...                      "
if [ $BLOCKHASH == $NEWBLOCKHASH ]
  then
    printf "FAIL (result:%s)\n" $NEWBLOCKHASH
    FAIL=$((FAIL+1))
  else
    printf "PASS\n"
    PASS=$((PASS+1))
fi
printf "        - Checking that freezing is now enabled (as the block that disabled it was dc'd)...  "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "true," ]
  then
    printf "   PASS\n"
    PASS=$((PASS+1))
  else
    printf "   FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Sending a 'disable freezing' transaction to DISABLE freezing\n"
TXID=$($SRCDIR/tokencore-cli --regtest sendtokendisablefreezing $ADDR 3)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'disable freezing' transaction was VALID... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                             PASS\n"
    PASS=$((PASS+1))
  else
    printf "                             FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking that freezing is now disabled... "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "false," ]
  then
    printf "                                            PASS\n"
    PASS=$((PASS+1))
  else
    printf "                                            FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
$SRCDIR/tokencore-cli --regtest generate 3 >$NUL
printf "   * Sending a 'enable freezing' transaction to ENABLE freezing\n"
TXID=$($SRCDIR/tokencore-cli --regtest sendtokenenablefreezing $ADDR 3)
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
printf "        - Checking the 'enable freezing' transaction was VALID...  "
RESULT=$($SRCDIR/tokencore-cli --regtest token_gettransaction $TXID | grep "valid" | grep -v "invalid" | cut -c12-)
if [ $RESULT == "true," ]
  then
    printf "                             PASS\n"
    PASS=$((PASS+1))
  else
    printf "                             FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "        - Checking that freezing is still disabled (due to waiting period)...       "
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "false," ]
  then
    printf "            PASS\n"
    PASS=$((PASS+1))
  else
    printf "            FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi
printf "   * Rolling back the chain to test reversing the last ENABLE FREEZEING tx\n"
BLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
BLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
$SRCDIR/tokencore-cli --regtest invalidateblock $BLOCKHASH >$NUL
PREVBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
$SRCDIR/tokencore-cli --regtest clearmempool >$NUL
$SRCDIR/tokencore-cli --regtest generate 1 >$NUL
NEWBLOCK=$($SRCDIR/tokencore-cli --regtest getblockcount)
NEWBLOCKHASH=$($SRCDIR/tokencore-cli --regtest getblockhash $(($BLOCK)))
printf "        - Checking the block count is the same as before the rollback...                        "
if [ $BLOCK == $NEWBLOCK ]
  then
    printf "PASS\n"
    PASS=$((PASS+1))
  else
    printf "FAIL (result:%s)\n" $NEWBLOCK
    FAIL=$((FAIL+1))
fi
printf "        - Checking the block hash is different from before the rollback...                      "
if [ $BLOCKHASH == $NEWBLOCKHASH ]
  then
    printf "FAIL (result:%s)\n" $NEWBLOCKHASH
    FAIL=$((FAIL+1))
  else
    printf "PASS\n"
    PASS=$((PASS+1))
fi
printf "        - Mining past prior activation period and checking that freezing is still disabled...   "
$SRCDIR/tokencore-cli --regtest generate 20 >$NUL
RESULT=$($SRCDIR/tokencore-cli --regtest token_getproperty 3 | grep "freezingenabled" | cut -c21-)
if [ $RESULT == "false," ]
  then
    printf "PASS\n"
    PASS=$((PASS+1))
  else
    printf "FAIL (result:%s)\n" $RESULT
    FAIL=$((FAIL+1))
fi

printf "\n"
printf "####################\n"
printf "#  Summary:        #\n"
printf "#    Passed = %d   #\n" $PASS
printf "#    Failed = %d    #\n" $FAIL
printf "####################\n"
printf "\n"
$SRCDIR/tokencore-cli --regtest stop


