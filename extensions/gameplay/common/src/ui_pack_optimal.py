"""Minimum-byte LZ tokenization for immutable UI assets, existing decoder ABI."""
def pack(raw):
    n=len(raw);matches=[];index={}
    for pos in range(n):
        best=0;distance=0;key=raw[pos:pos+3]
        for old in reversed(index.get(key,[])[-512:]):
            if pos-old>8191:continue
            count=0;limit=min(130,n-pos)
            while count<limit and raw[old+count]==raw[pos+count]:count+=1
            if count>best:best=count;distance=pos-old
            if best==limit:break
        matches.append((best,distance));index.setdefault(key,[]).append(pos)
    cost=[0]*(n+1);choice=[None]*n
    for pos in range(n-1,-1,-1):
        bestCost=10**9
        for count in range(1,min(127,n-pos)+1):
            candidate=1+count+cost[pos+count]
            if candidate<bestCost:bestCost=candidate;choice[pos]=('literal',count,0)
        limit,distance=matches[pos]
        for count in range(3,limit+1):
            candidate=3+cost[pos+count]
            if candidate<bestCost:bestCost=candidate;choice[pos]=('copy',count,distance)
        cost[pos]=bestCost
    out=bytearray();pos=0
    while pos<n:
        kind,count,distance=choice[pos]
        if kind=='literal':out.append(count);out.extend(raw[pos:pos+count])
        else:out.extend((128|(count-3),distance&255,distance>>8))
        pos+=count
    out.append(0)
    # Independent host decoder check, including overlapping copies.
    result=bytearray();p=0
    while out[p]:
        token=out[p];p+=1
        if token<128:result.extend(out[p:p+token]);p+=token
        else:
            distance=out[p]|out[p+1]<<8;p+=2
            for _ in range((token&127)+3):result.append(result[-distance])
    assert bytes(result)==raw
    return bytes(out)
