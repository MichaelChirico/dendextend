# Copyright (C) Tal Galili
#
# This file is part of dendextend.
#
# dendextend is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# dendextend is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/
#


### # ' @aliases 
### # ' set_leaves_attr
### # ' @usage
### # ' get_leaves_attr(object, labels = TRUE,...)
### # ' 
### # ' set_leaves_attr(object, ...) <- value
#' @title Get/set attributes of dendrogram's leaves
#' @export
#' @param object a dendrogram object 
#' @param attribute character scaler of the attribute (\code{attr})
#' we wish to get/set from the leaves
#' @param simplify logical. If TRUE (default), then the return vector is 
#' after using \code{unlist} on it.
#' @param ... not used
#' @source Heavily inspired by the code in the 
#' function \code{labels.dendrogram}, 
#' so credit should go to Martin Maechler.
#' @return 
#' A vector (or a list) with the dendrogram's leaves attribute
#' @seealso \link{get_nodes_attr}, \link{nnodes},
#' \link{nleaves}, \link{assign_values_to_leaves_nodePar}
#' @examples
#' # define dendrogram object to play with:
#' hc <- hclust(dist(USArrests[1:3,]), "ave")
#' dend <- as.dendrogram(hc)
#' 
#' # get_leaves_attr(dend) # error :)
#' get_leaves_attr(dend, "label")
#' labels(dend, "label")
#' get_leaves_attr(dend, "height") # should be 0's
#' get_nodes_attr(dend, "height") 
#' 
#' 
#' get_leaves_attr(dend, "leaf") # should be TRUE's
#' get_nodes_attr(dend, "leaf") # conatins NA's
#' 
#' 
#' get_leaves_attr(dend, "members") # should be 1's
#' get_nodes_attr(dend, "members") # 
#' 
#' 
#' get_leaves_attr(dend, "members",simplify = FALSE) # should be 1's
#' 
#' 
get_leaves_attr <- function (object, attribute, simplify = TRUE, ...) {
   if(!inherits(object,'dendrogram')) warning("'object' should be a dendrogram.")   
   if(missing(attribute)) stop("'attribute' parameter is missing.")
   
   get_attr_from_leaf <- function(dend_node) {
      if(is.leaf(dend_node)) attr(dend_node, attribute)
   }   

   ret <- dendrapply(object, get_attr_from_leaf)   
   if(simplify) ret <- unlist(ret)   
   
   return(ret)   
}










#' @title Get attributes of dendrogram's nodes
#' @description
#' Allows easy access to attributes of branches and/or leaves, with option
#' of returning a vector with/withough NA's (for marking the missing attr value)
#' 
#' @export
#' @param object a dendrogram object 
#' @param attribute character scaler of the attribute (\code{attr})
#' we wish to get from the nodes
#' @param include_leaves logical. Should leaves attributes be included as well?
#' @param include_branches logical. Should non-leaf (branch node) 
#' attributes be included as well?
#' @param na.rm logical. Should NA attributes be REMOVED from the resulting vector?
#' @param ... not used
#' @source Heavily inspired by the code in the 
#' function \code{labels.dendrogram}, 
#' so credit should go to Martin Maechler.
#' @return 
#' A vector with the dendrogram's nodes attribute. If an attribute is missing
#' from some nodes, it will return NA in that vector.
#' @seealso \link{get_leaves_attr}, \link{nnodes}, \link{nleaves}
#' @examples
#' # define dendrogram object to play with:
#' hc <- hclust(dist(USArrests[1:3,]), "ave")
#' dend <- as.dendrogram(hc)
#' 
#' # get_leaves_attr(dend) # error :)
#' get_leaves_attr(dend, "label")
#' labels(dend, "label")
#' get_leaves_attr(dend, "height") # should be 0's
#' get_nodes_attr(dend, "height") 
#' 
#' 
#' get_leaves_attr(dend, "leaf") # should be TRUE's
#' get_nodes_attr(dend, "leaf") # conatins NA's
#' 
#' 
#' get_leaves_attr(dend, "members") # should be 1's
#' get_nodes_attr(dend, "members", include_branches = FALSE, na.rm = TRUE) # 
#' get_nodes_attr(dend, "members") # 
#' get_nodes_attr(dend, "members", include_leaves = FALSE, na.rm = TRUE) # 
#' 
#' 
#' hang_dend <- hang.dendrogram(dend)
#' get_leaves_attr(hang_dend, "height") # no longer 0!
#' get_nodes_attr(hang_dend, "height") # does not include any 0s!
#' 
#' # does not include leaves values:
#' get_nodes_attr(hang_dend, "height", include_leaves = FALSE) 
#' # remove leaves values all together:
#' get_nodes_attr(hang_dend, "height", include_leaves = FALSE, na.rm = TRUE) 
#' 
#' 
#' 
#' \donotrun{
#' require(microbenchmark)
#' # get_leaves_attr is twice faster than get_nodes_attr
#' microbenchmark(   get_leaves_attr(dend, "members"), # should be 1's
#'                     get_nodes_attr(dend, "members", include_branches = FALSE, na.rm = TRUE)
#'                )
#' }
#' 
get_nodes_attr <- function (object, attribute, include_leaves = TRUE,
                            include_branches = TRUE,
                            na.rm = FALSE, ...) {
   if(!inherits(object,'dendrogram')) warning("'object' should be a dendrogram.")   
   if(missing(attribute)) stop("'attribute' parameter is missing.")

   #### for some reason, this doesn't work:   
   #    get_attr_from_node <- function(dend_node) {
   #       i_attr <- attr(dend_node, attribute)
   #       ifelse(is.null(i_attr), NA, i_attr) 
   #    }   
   #    
   #    return((dendrapply(object, get_attr_from_node)))   
   
   
   object_attr <- rep(NA, nnodes(object))
   
   # this function is used to modify object_attr. What it returns is not important.
   i_node <- 0
   get_attr_from_node <- function(dend_node) {
      i_node <<- i_node + 1
      
      # if we should not include_leaves, then we skip when a leaf is encountered.
      if(!include_leaves && is.leaf(dend_node)) return(NULL)
      if(!include_branches && !is.leaf(dend_node)) return(NULL)      
      
      i_attr <- attr(dend_node, attribute)
      if(!is.null(i_attr)) object_attr[i_node] <<- i_attr
      return(NULL)
   }   
   dendrapply(object, get_attr_from_node)   

   # as.vector is to remove all classes of the na.omit
   # thank you Prof. Brian Ripley http://tolstoy.newcastle.edu.au/R/e2/devel/07/01/1965.html
   if(na.rm) object_attr <- as.vector(na.omit(object_attr)) 
   
   return(object_attr)   
}











#   ' @export
#' @title recursivly apply a function on a list
#' @description
#' recursivly apply a function on a list - and returns the output as a list, 
#' following the naming convention in the {plyr} package
#' the big difference between this and rapply is that this will also apply 
#' the function on EACH element of the list, even if it's not a "terminal node"
#' inside the list tree.
#' An attribute is added to indicate if the value returned is 
#' from a branch or a leaf.
#' @param x a list.
#' @param FUN a function to apply on each element of the list
#' @param add_notation logical. Should each node be 
#' added a "position_type" attribute, stating if it is a "Branch" or a "Leaf".
#' @param ... not used.
#' @return a list with ALL of the nodes (from the original "x" list),
#' that FUN was applied on.
#' 
#' @examples
#' \dontrun{
#' x <- list(1)
#' x
#' rllply(x, function(x){x}, add_notation  = TRUE)
#' 
#' x <- list(1, 2, list(31))
#' x
#' rllply(x, function(x){x}, add_notation  = TRUE)
#'                      # the first element is the entire tree
#'                            # after FUN was applied to its root element.
#' 
#' hc <- hclust(dist(USArrests[1:4,]), "ave")
#' dend <- as.dendrogram(hc)
#' rllply(dend, function(x){attr(x, "height")})
#' rllply(dend, function(x){attr(x, "members")})
#' }
rllply <- function(x, FUN,add_notation = FALSE, ...)
{   
   if(is.list(x)) {
      output <- list()
      for(i in seq_len(length(x)))
      {		
         output[[i]] <- list(rllply(x[[i]], FUN,...))
         if(add_notation) attr(output[[i]][[1]], "position_type") <- "Branch"
      }
      output <- list(FUN(x,...), output)
   } else {
      output <- FUN(x,...)
      if(add_notation) attr(output, "position_type") <- "Leaf"	
   }   
   return(output)
}






#' @title Get height attributes from a dendrogram
#' @export
#' @param tree a dendrogram.
#' @param sort logical. Should the heights be sorted?
#' @param decreasing logical. Should the sort be increasing or decreasing? Not available for partial sorting.
#' @param ... not used.
#' @return 
#' a vector of the dendrogram's nodes heights (excluding leaves).
#' 
#' @examples
#' 
#' hc <- hclust(dist(USArrests[1:4,]), "ave")
#' dend <- as.dendrogram(hc)
#' get_branches_heights(dend)
#' 
#' 
get_branches_heights <- function(tree, sort = TRUE, decreasing = FALSE, ...)
{
#    height <- unlist(rllply(tree, function(x){attr(x, "height")}))
#    height <- get_nodes_attr(tree, "height") 
#    height <- height[height != 0] # include only the non zero values
   
   height <- get_nodes_attr(tree, "height", include_leaves = FALSE, na.rm = TRUE)   
   if(sort) height <- sort(height, decreasing=decreasing) 	# sort the height
   
   return(height)
}












#' @title Hang dendrogram leaves
#' @export
#' @description
#' Adjust the height attr in all of the dendrogram leaves so that
#'  the tree will hang. This is similar to as.dendrogram(hclust, hang=0.1)
#'  Only that it now works on other object than hclust turned into a dendrogram.
#'  For example, this allows us to hang non-binary trees.
#'  
#' @param dend a dendrogram object 
#' @param hang The fraction of the plot height by which labels should hang below 
#' the rest of the plot. A negative value will cause the labels to 
#' hang down from 0.
#' @param hang_height is missing, then using "hang". If a number is given,
#' it overrides "hang" (except if "hang" is negative)
#' @param ... not used
#' @return 
#' A dendrogram, after adjusting the height attr in all of its leaves, 
#' so that the tree will hang.
#' @source 
#' Noticing that as.dendrogram has a "hang" parameter was thanks to Enrique Ramos's answer here:: 
#' \url{http://stackoverflow.com/questions/17088136/plot-horizontal-dendrogram-with-hanging-leaves-r}
#' @examples
#' 
#' # define dendrogram object to play with:
#' hc <- hclust(dist(USArrests[1:5,]), "ave")
#' dend <- as.dendrogram(hc)
#' 
#' par(mfrow = c(1,2))
#' plot(hang.dendrogram(dend))
#' plot(hc)
#' # identical(as.dendrogram(hc, hang = 0.1), hang.dendrogram(dend, hang = 0.1))
#' # TRUE!!
#' 
#' 
#' par(mfrow = c(1,4))
#' 
#' plot(dend)
#' plot(hang.dendrogram(dend, hang = 0.1))
#' plot(hang.dendrogram(dend, hang = 0))
#' plot(hang.dendrogram(dend, hang = -0.1))
#' 
#' par(mfrow = c(1,1))
#' plot(hang.dendrogram(dend), horiz = TRUE)
#'  
#'  
hang.dendrogram <- function(dend,hang = 0.1,hang_height, ...) {
   if(!inherits(dend,'dendrogram')) stop("'dend' should be a dendrogram.")   
   
   #    get_heights.dendrogram
   if(missing(hang_height)) hang_height <- attr(dend, "height")*hang
   
   fix_height_attr_per_leaf <- function(dend_node)
   {
      if(!is.leaf(dend_node)) {
         dend_node_height <- attr(dend_node, "height")
         
         for(i_nodes in seq_len(length(dend_node))) {
            if(is.leaf(dend_node[[i_nodes]])) {
               if(hang < 0) {
                  attr(dend_node[[i_nodes]], "height") <- 0
               } else {
                  attr(dend_node[[i_nodes]], "height") <- dend_node_height - hang_height
               }
               
               dend_node[[i_nodes]] <- unclass(dend_node[[i_nodes]]) # makes sure we don't inherent any classes...
               
            } else {
               dend_node[[i_nodes]] <- 
                  fix_height_attr_per_leaf(dend_node[[i_nodes]])
            }           
         }
         
      }
      return(unclass(dend_node))
   }
   
   dend <- fix_height_attr_per_leaf(dend)   
   class(dend) <- "dendrogram"
   return(dend)
}

# unclass(dend)
# unclass(hang.dendrogram(dend))
# unclass(unclass(unclass(hang.dendrogram(dend))))










#' @title Assign values to nodePar of dendrogram's leaves
#' @export
#' @description
#' Go through the dendrogram leaves and updates the values inside its nodePar
#' @param object a dendrogram object 
#' @param value a new value vector for the nodePar attribute. It should be 
#' the same length as the number of leaves in the tree. If not, it will recycle
#' the value and issue a warning.
#' @param nodePar the value inside nodePar to adjust.
#' @param ... not used
#' @return 
#' A dendrogram, after adjusting the nodePar attribute in all of its leaves, 
#' @seealso \link{get_leaves_attr}
#' @examples
#' 
#' \donotrun{
#' 
#' hc <- hclust(dist(USArrests[1:5,]), "ave")
#' dend <- as.dendrogram(hc)
#' 
#' 
#' # reproduces "labels_colors<-" 
#' # although it does force us to run through the tree twice, 
#' # hence "labels_colors<-" is better...
#' plot(dend)
#' dend <- assign_values_to_leaves_nodePar(object=dend, value = c(3,2), nodePar = "lab.col")
#' plot(dend)
#' # fix the annoying pch=1:
#' dend <- assign_values_to_leaves_nodePar(dend, NA, "pch")
#' plot(dend)
#' # adjust the cex:
#' dend <- assign_values_to_leaves_nodePar(dend, 2, "lab.cex")
#' plot(dend)
#' 
#' get_leaves_attr(dend, "nodePar", simplify=FALSE)
#' 
#' }
#' 
assign_values_to_leaves_nodePar <- function(object, value, nodePar,...) {
   if(!is.dendrogram(object)) stop("'object' should be a dendrogram.")   
   
   leaves_length <- length(order.dendrogram(object)) # length(labels(object)) # it will be faster to use order.dendrogram than labels...   
   if(leaves_length > length(value)) {
      warning("Length of value vector was shorter than the number of leaves - vector value recycled")
      value <- rep(value, length.out = leaves_length)
   }       
   
   set_value_to_leaf <- function(dend_node) {
      if(is.leaf(dend_node)) {			
         i_leaf_number <<- i_leaf_number + 1
         attr(dend_node, "nodePar")[[nodePar]] <- value[i_leaf_number] # this way it doesn't erase other nodePar values (if they exist)
         
         if(length(attr(dend_node, "nodePar")) == 0) attr(dend_node, "nodePar") <- NULL # remove nodePar if it is empty
      }
      return(unclass(dend_node))
   }   
   i_leaf_number <- 0
   new_dend_object <- dendrapply(object, set_value_to_leaf)
   class(new_dend_object) <- "dendrogram"
   return(new_dend_object)
}


