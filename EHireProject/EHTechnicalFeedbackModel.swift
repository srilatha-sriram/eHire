//
//  EHTechnicalFeedbackModel.swift
//  EHire
//
//  Created by Tharani P on 29/12/15.
//  Copyright © 2015 Exilant Technologies. All rights reserved.
//

import Cocoa

class EHTechnicalFeedbackModel: NSObject
{
    var commentsOnCandidate: String?
    var commentsOnTechnology: String?
    var techLeadName: String?
    var modeOfInterview: String?
    var ratingOnCandidate: Int16?
    var ratingOnTechnical: Int16?
    var recommendation: String?
    var candidate: EHCandidateDetails?
    var skillSet : [EHSkillSet] = []
    var designation: String?
}
