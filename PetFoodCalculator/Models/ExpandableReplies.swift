//
//  ExpandableReplies.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 9/19/24.
//

import FirebaseFirestore

struct ExpandableReplies{
    var isExpanded = false
    var replies : [DocumentSnapshot]
}
