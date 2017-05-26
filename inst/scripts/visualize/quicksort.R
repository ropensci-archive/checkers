# quicksort from http://www.geeksforgeeks.org/iterative-quick-sort/

# A utility function to swap two elements
swap <- function(a, b)
{
  # Don't swap if the elements are the same
  if(a==b) return()
  
  # Keep a record of what pairs are being swapped
  swaps_pos <<- rbind(swaps_pos, matrix(c(a, b), ncol=2, nrow=1))
  swaps_ids <<- rbind(swaps_ids, matrix(c(tosortids[a], tosortids[b]), ncol=2, nrow=1))
  
  # Do the swapping. This has 'side-effects' (i.e., the main effect) on sorted
  t <- sorted[a]
  sorted[a] <<- sorted[b]
  sorted[b] <<- t
  
  # Keep a record of where the IDs go
  t <- tosortids[a]
  tosortids[a] <<- tosortids[b]
  tosortids[b] <<- t
  
  # Keep a record of results of swaps
  steps_vals <<- rbind(steps_vals, matrix(sorted, ncol=length(sorted), nrow=1))
  steps_ids  <<- rbind(steps_ids,  matrix(tosortids, ncol=length(tosortids), nrow=1))
}

# Identify a pivot index that partitions an array around the value of element h.
# The pivot p is the element originally at h; all elements with values less than
# p's are moved to the left, then p is placed at the first position to the right
# of those values. 
# sorted --> Array to be sorted, 
# l  --> Starting index (low), 
# h --> Ending index (high)
partition <- function(l, h) {
  x = sorted[h]
  i = l - 1
  
  for (j in l:(h-1)) {
    if (sorted[j] <= x) {
      i <- i + 1
      swap(i, j)
    }
  }
  swap(i+1, h)
  return(i + 1)
}

# tosort --> Array to be sorted, 
# l  --> Starting index (low), 
# h  --> Ending index (high)
quickSortIterative <- function(tosort, l=1, h=length(tosort)) {
  num_vals <- h-l+1
  
  # Prepare to document all the swaps we make. swaps gets edited by swap()
  swaps_pos <<- matrix(ncol=2, nrow=0)
  swaps_ids <<- matrix(ncol=2, nrow=0)
  steps_vals <<- matrix(tosort, nrow=1)
  steps_ids <<- matrix(seq_len(num_vals), nrow=1)
  
  # Make a copy of arr that we can manipulate, and a vector of IDs we can
  # manipulate in parallel to track where IDs are going
  sorted <<- tosort
  tosortids <<- seq_len(num_vals)
  
  # Create an auxiliary stack about as long as tosort; we'll use less than that.
  # the stack will contain partition bounds
  stack <- integer(num_vals);
  
  # initialize top of stack
  top <- 0
  
  # push initial values of l and h to stack
  stack[top <- top + 1] = l
  stack[top <- top + 1] = h
  
  # Keep popping from stack while is not empty
  while ( top > 0 ) {
    # Pop h and l (i.e., consider the next partition on the stack)
    h <- stack[top]
    l <- stack[top - 1]
    top <- top - 2
    
    # Set pivot element at its correct position in sorted array. The "correct
    # position" is the position at which there are no elements with values
    # greater than p's to the left of it. This does some sorting along the way.
    p <- partition(l, h)
    
    # If there are elements on left side of pivot, push left side to stack
    if ( p-1 > l ) {
      stack[top <- top + 1] = l
      stack[top <- top + 1] = p - 1
    }
    
    # If there are elements on right side of pivot, push right side to stack
    if ( p+1 < h ) {
      stack[top <- top + 1] = p + 1
      stack[top <- top + 1] = h
    }
  }
  
  out <- list(sorted=sorted, swaps_pos=swaps_pos, swaps_ids=swaps_ids, steps_vals=steps_vals, steps_ids=steps_ids)
  rm(sorted, swaps_pos, swaps_ids, steps_vals, steps_ids, envir=.GlobalEnv)
  return(out)
}

# ## Demo ##
# arr <- c(40,20,50,10,30)
# x <- quickSortIterative(arr)
# 
# ## Tests ##
# 
# # redo the steps using ids
# ids <- 1:length(arr)
# for(i in 1:nrow(x$swaps_ids)) {
#   swap <- x$swaps_ids[i,]
#   elem <- match(swap, ids)
#   t <- ids[elem[1]]
#   ids[elem[1]] <- ids[elem[2]]
#   ids[elem[2]] <- t
# }
# ids
# # compare ids to the final row of steps_ids - should be the same
# tail(x$steps_ids,1)
# # show that the ids are in order - ordering arr by ids should give sorted arr
# arr[ids]
