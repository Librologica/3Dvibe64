"""Deterministic aligned placement with an explicit finite search budget."""

class PlacementFailure(ValueError):
    def __init__(self,reason,nodes,budget):
        self.reason=reason;self.nodes=nodes;self.budget=budget
        super().__init__(f'{reason}: nodes={nodes}, budget={budget}')

def bounded_place(sizes,gaps,budget):
    items=sorted(sizes.items(),key=lambda pair:-pair[1]);nodes=0
    def attempt(all_positions):
        seen=set()
        def solve(i,free,placed):
            nonlocal nodes
            if nodes>=budget:raise PlacementFailure('SEARCH_BUDGET_EXHAUSTED',nodes,budget)
            nodes+=1
            if i==len(items):return placed,free
            state=(i,tuple(sorted(free)))
            if state in seen:return None
            seen.add(state)
            remaining=sum(s+(0 if n in ('tables','data') else 32) for n,s in items[i:])
            if sum(b-a for a,b in free)<remaining:return None
            name,size=items[i];align=256 if name=='tables' else 2
            need=size+(0 if name in ('tables','data') else 32)
            choices=[]
            for j,(a,b) in enumerate(free):
                first=(a+align-1)//align*align
                starts=range(first,b-need+1,align) if all_positions else [first]
                for start in starts:
                    if start+need<=b:choices.append((int(start!=first),b-start-need,j,start))
            for _,_,j,start in sorted(choices):
                a,b=free[j];rest=free[:j]+free[j+1:]
                if a<start:rest.append((a,start))
                if start+need<b:rest.append((start+need,b))
                result=solve(i+1,rest,{**placed,name:(start,start+need)})
                if result:return result
            return None
        return solve(0,list(gaps),{})
    # Preserve every previously successful first-address allocation unchanged.
    result=attempt(False)
    if result:return result,dict(nodes=nodes,budget=budget,additionalPositions=False)
    result=attempt(True)
    if result:return result,dict(nodes=nodes,budget=budget,additionalPositions=True)
    # All aligned placements have been exhausted, not merely the first address
    # or a heuristic order. Fixed item order loses no solutions when every
    # legal aligned address is enumerated.
    raise PlacementFailure('NO_ALIGNED_PLACEMENT',nodes,budget)
