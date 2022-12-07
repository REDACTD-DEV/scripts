import time
startTime = time.time()
import hashlib

hashFile = open("%USERPROFILE%/Documents/Scripts/hashes.txt", "r")
wordListFile = "%USERPROFILE%/Documents/Scripts/rockyou.txt"

def isValidHash(hashType, hash):
    match hashType:
        case "md5":
            length = 32
        case "sha256":
            length = 64
        case "sha512":
            length = 128
    try:
        int(hash, 16)
    except:
        return False
    if len(hash) != length:
        return False
    else:
        return True

md5List = []
sha256List = []
sha512List = []
invalidHashList = []
def hashSort():
    for hash in hashFile:
        hash = hash.rstrip()
        if isValidHash("md5", hash) == True:
            md5List.append(hash)
        if isValidHash("sha256", hash) == True:
            sha256List.append(hash)
        if isValidHash("sha512", hash) == True:
            sha512List.append(hash)
        if (isValidHash("md5", hash) == False) and (isValidHash("sha256", hash) == False) and (isValidHash("sha512", hash) == False):
            invalidHashList.append(hash)

def crack(wordListFile, hashList, algorithm):
    if hashList:
        wordlist = open(wordListFile,'rb')
        crackedHashes = 0
        for word in wordlist:
            hash_algorithm = getattr(hashlib, algorithm)()
            word = word.rstrip()
            hash_algorithm.update(word)
            calculatedhash = hash_algorithm.hexdigest()
            for hash in hashList:
                if hash== calculatedhash:
                    print(hash + ":" + word.decode())
                    crackedHashes += 1
                    break
            if crackedHashes == len(hashList):
                break
        print(crackedHashes, "out of", len(hashList), algorithm, "hashes cracked")
    wordlist.close()

hashSort()
crack(wordListFile, md5List, "md5")
crack(wordListFile, sha256List, "sha256")
crack(wordListFile, sha512List, "sha512")

if len(invalidHashList) > 0:
    print("There are", len(invalidHashList), "invalid hashes in the hash file.")

executionTime = (time.time() - startTime)
print('Execution time in seconds: ' + str(executionTime))
