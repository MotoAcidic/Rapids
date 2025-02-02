/**
 * @file walletcache.cpp
 *
 * Provides a cache of wallet balances and functionality for determining whether
 * Token state changes affected anything in the wallet.
 */

#include "tokencore/walletcache.h"

#include "tokencore/log.h"
#include "tokencore/tokencore.h"
#include "tokencore/tally.h"
#include "tokencore/walletutils.h"

#include "init.h"
#include "sync.h"
#include "uint256.h"
#ifdef ENABLE_WALLET
#include "wallet/wallet.h"
#endif

#include <stdint.h>
#include <algorithm>
#include <list>
#include <map>
#include <set>
#include <string>
#include <utility>
#include <vector>

namespace mastercore
{
//! Map of wallet balances
static std::map<std::string, CMPTally> walletBalancesCache;

/**
 * Updates the cache with the latest state, returning true if changes were made to wallet addresses (including watch only).
 *
 * Also prepares a list of addresses that were changed (for future usage).
 */
int WalletCacheUpdate()
{
    if (msc_debug_walletcache) PrintToLog("WALLETCACHE: Update requested\n");
    int numChanges = 0;
    std::set<std::string> changedAddresses;

    LOCK(cs_tally);

    for (std::unordered_map<std::string, CMPTally>::iterator my_it = mp_tally_map.begin(); my_it != mp_tally_map.end(); ++my_it) {
        const std::string& address = my_it->first;

        // determine if this address is in the wallet
        int addressIsMine = IsMyAddress(address);
        if (!addressIsMine) {
            if (msc_debug_walletcache) PrintToLog("WALLETCACHE: Ignoring non-wallet address %s\n", address);
            continue; // ignore this address, not in wallet
        }

        // obtain & init the tally
        CMPTally& tally = my_it->second;
        tally.init();

        // check cache for miss on address
        std::map<std::string, CMPTally>::iterator search_it = walletBalancesCache.find(address);
        if (search_it == walletBalancesCache.end()) { // cache miss, new address
            ++numChanges;
            changedAddresses.insert(address);
            walletBalancesCache.insert(std::make_pair(address,tally));
            if (msc_debug_walletcache) PrintToLog("WALLETCACHE: *CACHE MISS* - %s not in cache\n", address);
            continue;
        }

        // check cache for miss on balance - TODO TRY AND OPTIMIZE THIS
        CMPTally &cacheTally = search_it->second;
        uint32_t propertyId;
        while (0 != (propertyId = (tally.next()))) {
            if (tally.getMoney(propertyId, BALANCE) != cacheTally.getMoney(propertyId, BALANCE) ||
                    tally.getMoney(propertyId, PENDING) != cacheTally.getMoney(propertyId, PENDING) ||
                    tally.getMoney(propertyId, SELLOFFER_RESERVE) != cacheTally.getMoney(propertyId, SELLOFFER_RESERVE) ||
                    tally.getMoney(propertyId, ACCEPT_RESERVE) != cacheTally.getMoney(propertyId, ACCEPT_RESERVE) ||
                    tally.getMoney(propertyId, METADEX_RESERVE) != cacheTally.getMoney(propertyId, METADEX_RESERVE)) { // cache miss, balance
                ++numChanges;
                changedAddresses.insert(address);
                walletBalancesCache.erase(search_it);
                walletBalancesCache.insert(std::make_pair(address,tally));
                if (msc_debug_walletcache) PrintToLog("WALLETCACHE: *CACHE MISS* - %s balance for property %d differs\n", address, propertyId);
                break;
            }
        }
    }
    if (msc_debug_walletcache) PrintToLog("WALLETCACHE: Update finished - there were %d changes\n", numChanges);
    return numChanges;
}


} // namespace mastercore
