//
//  BRChainParams.h
//
//  Created by Aaron Voisine on 1/10/18.
//  Copyright (c) 2019 breadwallet LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#ifndef BRChainParams_h
#define BRChainParams_h

#include "BRMerkleBlock.h"
#include "BRPeer.h"
#include "BRSet.h"
#include "BRPeer.h"
#include <assert.h>

typedef struct {
    uint32_t height;
    UInt256 hash;
    uint32_t timestamp;
    uint32_t target;
} BRCheckPoint;

typedef struct {
    const char * const *dnsSeeds; // NULL terminated array of dns seeds
    uint16_t standardPort;
    uint32_t magicNumber;
    uint64_t services;
    int (*verifyDifficulty)(const BRMerkleBlock *block, const BRSet *blockSet); // blockSet must have last 2016 blocks
    const BRCheckPoint *checkpoints;
    size_t checkpointsCount;
} BRChainParams;

static const char *BRMainNetDNSSeeds[] = {
    "68.183.81.213", "174.138.61.12", "165.22.155.173", "192.171.18.198", "54.37.235.120", "51.38.83.67", "79.137.39.240", "51.38.115.250", "54.38.53.207", "178.128.111.9", "159.89.168.255", "167.114.145.147", NULL
};

static const char *BRTestNetDNSSeeds[] = {
    "testnet-seed.breadwallet.com.", "testnet-seed.bitcoin.petertodd.org.", "testnet-seed.bluematt.me.",
    "testnet-seed.bitcoin.schildbach.de.", NULL
};

// blockchain checkpoints - these are also used as starting points for partial chain downloads, so they must be at
// difficulty transition boundaries in order to verify the block difficulty at the immediately following transition
static const BRCheckPoint BRMainNetCheckpoints[] = {
    {      0, uint256("00000f98da995de0ef1665c7d3338687923c1199230a44ecbdb5cec9306e4f4e"), 1489479450, 0x1e0fffff },
    {     10, uint256("000000510a92dcd0364d79ace286a8d44c060f96eff907f649c00b120901fa69"), 1490761311, 0x1e015676 },
    {  11810, uint256("000000000011a409fad375babe9e521e31095de1707e261ca783242c95827593"), 1497384553, 0x1b66ddda },
    {  11816, uint256("3f90dc9f885df3e167a4ad3a665ffc5282e3d4cd2291b616abc3ddc8b623ffdc"), 1497551622, 0x1e0fffff },
    {  11920, uint256("000000000949e8afa1fc49b5faf29bdf3b7ed39ea7f230637fafbb7cf7b04956"), 1498210216, 0x1c192d7d },
    {  15160, uint256("e31d9b1163cb7193f35c5716dfc22e86fdabb7206b3c5a27967c8f3a83892633"), 1499218627, 0x1c0102d3 },
    { 128926, uint256("79aa1982dcee614dadb2857a3491c1c900bd715af45cdb4f9779872280161be5"), 1541539015, 0x1b082285 },
    { 146500, uint256("540485ed391d8fb089eeb28ce9e4b61425b9f95d831855944f98b995e4407cec"), 1544562461, 0x1b0fdda7 },
    { 148000, uint256("e51e81dd77a36b5d5db7e273463fc034360d779076d8a31ebfb8dd3d5ebd7a3d"), 1544823071, 0x1b1562be },
    { 164000, uint256("23f70286427e411bf633cef753efbe27eb066edcc15bbbb230d4f953023f3c1e"), 1547577181, 0x1b17a1ba },
    { 170000, uint256("59ea4fe7ee342f2280470def1f122d7c098ace083c3d914013ce7694700cb788"), 1548609139, 0x1b0c0554 },
    { 182749, uint256("8ae2f1500b56817d8fab7acee7bf83814d56d68f0d07e4fe45384752481023c0"), 1550827845, 0x1b3240ed },
    { 182750, uint256("1c84752e501b27cdf561e1e96d0c15dc15925462845a62ee508ae98bb089216d"), 1550827881, 0x1e02f881 },
    { 182751, uint256("268f8621be92a8a09d7fa10e8ddf62e4a275230a8212c718dad1d9bc98669271"), 1550827888, 0x1e0fffff },
    { 199000, uint256("dc78cfb171a2ca24e235df6ec716d5a052dc89705c5af0393fad359b12753390"), 1551900379, 0x1919db4b },
    { 220500, uint256("d93ed4534386fadd560b979f4476abf150a4b7b5515ab8b8e2ef878af9022a09"), 1553337207, 0x1920bf7a },
    { 250500, uint256("0e834ba44fa318819d9a5cd69f6420bbd9585c4a83f392365a3f431ada2b2330"), 1555341053, 0x191ca340 },
	{ 275000, uint256("ad2f863ef5ada8871f18c7391a20f6b3d6f9d7875c0f1b0f23a643e28dfc5507"), 1556972337, 0x192f3df1 },
	{ 300500, uint256("a7900680655d51df76e6e6ac1e2967b6a1c05bcfbbdb75b2ba3c86d2194d2e75"), 1558675403, 0x1928bfb8 },
	{ 310000, uint256("4f3e845e2cc8d2d13054629f2aff743ef16d7484c3acdf6aee7299af009e16a0"), 1559310636, 0x1937112c }
	//{ 350000,
};

static const BRCheckPoint BRTestNetCheckpoints[] = {
    {       0, uint256("0x00003892b5c64b1ef04b95e06bb019731ffc9d4031706d8a993e6103e7fc4a2d"), 1296688602, 0x1d00ffff }
    //{ 0, 
};

static int BRMainNetVerifyDifficulty(const BRMerkleBlock *block, const BRSet *blockSet)
{
    const BRMerkleBlock *previous, *b = NULL;
    uint32_t i;
    
    assert(block != NULL);
    assert(blockSet != NULL);
    
    // check if we hit a difficulty transition, and find previous transition block
    if ((block->height % BLOCK_DIFFICULTY_INTERVAL) == 0) {
        for (i = 0, b = block; b && i < BLOCK_DIFFICULTY_INTERVAL; i++) {
            b = BRSetGet(blockSet, &b->prevBlock);
        }
    }
    
    previous = BRSetGet(blockSet, &block->prevBlock);
    return BRMerkleBlockVerifyDifficulty(block, previous, (b) ? b->timestamp : 0);
}

static int BRTestNetVerifyDifficulty(const BRMerkleBlock *block, const BRSet *blockSet)
{
    return 1; // XXX skip testnet difficulty check for now
}

static const BRChainParams BRMainNetParams = {
    BRMainNetDNSSeeds,
    5817,                  // standardPort
    0xb5a2f1b4,            // magicNumber
    0,                     // services
    BRMainNetVerifyDifficulty,
    BRMainNetCheckpoints,
    sizeof(BRMainNetCheckpoints)/sizeof(*BRMainNetCheckpoints)
};

static const BRChainParams BRTestNetParams = {
    BRTestNetDNSSeeds,
    15817,                 // standardPort
    0xe1e2e3e7,            // magicNumber
    0,                     // services
    BRTestNetVerifyDifficulty,
    BRTestNetCheckpoints,
    sizeof(BRTestNetCheckpoints)/sizeof(*BRTestNetCheckpoints)
};

#endif // BRChainParams_h
