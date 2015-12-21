//
//  EHTechnologyViewController.swift
//  EHire
//  This is the ViewController for handling Technology list and Dates. This is the delegate for Date popover and AddTechnology sheet.
//  This is a data source for the Outline view.
//
//  Created by ajaybabu singineedi on 09/12/15.
//  Copyright © 2015 Exilant Technologies. All rights reserved.
//

import Cocoa

class EHTechnologyViewController: NSViewController,NSOutlineViewDelegate,NSOutlineViewDataSource,DataCommunicator,FeedbackDelegate {
    
    // Technology View
    @IBOutlet weak var sourceList: NSOutlineView!
    
    //Set the content of source list in the outlineVew as the technology list/array
    var technologyArray = [EHTechnology]()
    var addTechnologyController:EHAddTechnologyController?
    var selectedTechnologyIndex:Int?
    
    // Add Interview Date
    var datePopOverController : EHPopOverController?
    var datePopOver:NSPopover = NSPopover()
    
    //View for listing the canditates
    @IBOutlet weak var candidateView: NSView!
    var candidateController:EHCandidateController?
    var isCandidatesViewLoaded = false
    
    //Feedback View related
    var feedbackViewController:EHFeedbackViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        getSourceListContent()
    }
    
    //PRAGMAMARK: - outlineview datasource  methods
    // This datasource method returns the child at a given index
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject
    {
        // it 'item' is nil, technology has to be returned. Else, item's(technology) child(date) at that index has to be returned.
        if   item != nil
        {
            if item is EHTechnology{
                let technology = item as! EHTechnology
                return technology.interviewDates[index]
            }
        }
        return technologyArray[index]
        
    }
    
    
    // This datasource method returns true if the item(technology) has any children(date)
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool
    {
        if item is EHTechnology{
            let technology = item as! EHTechnology
            return (technology.interviewDates.count) > 0 ? true : false
        }
        return false
    }
    
    // This datasource method returns the count of items (when called for parent/technology) 
    // or number of children(dates) when called for interview dates.
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int
    {
        if   item != nil
        {
            if item is EHTechnology{
                let technology = item as! EHTechnology
                return technology.interviewDates.count
            }
        }
        return technologyArray.count
    }
    
    //PRAGMAMARK: - outlineview delegate  methods
    //This delegate method sets isCandidatesViewLoaded based on which item (technology/date) is selected.
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        
        switch item{
            
        case  _ as EHTechnology:
            
            print("Its a Technology ")
            
            if isCandidatesViewLoaded{
                
                candidateController?.view.removeFromSuperview()
                
                print("Removed")
                
                isCandidatesViewLoaded = false
            }
           
        case  _ as EHInterviewDate:
            
            if !isCandidatesViewLoaded{
                
                print("Loaded")
                
                candidateController = self.storyboard?.instantiateControllerWithIdentifier("candidateObject") as? EHCandidateController
                
                candidateController?.delegate = self
                
                self.candidateView.addSubview((candidateController?.view)!)
                
                isCandidatesViewLoaded = true
            }
            
        default:
            
            print("Never")
            
        }
        
        return true
    }
    
    // This delgate provides the content for each item (technology/date) of the outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView?
    {
        
        
        let cell:NSTableCellView?
        if item is EHInterviewDate
        {
            let child = sourceList.makeViewWithIdentifier("child", owner: nil) as! EHInterviewDateCustomCell
            
            let x  = item as! EHInterviewDate
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let dateString = dateFormatter.stringFromDate(x.scheduleInterviewDate)
            child.lblName.stringValue = dateString
            
            cell = child
            
            
        }
        else
        {
            let parent = sourceList.makeViewWithIdentifier("Parent", owner: nil) as! EHTechnologyCustomCell
            
            let x = item as! EHTechnology
            parent.lblParent.stringValue = x.technologyName
            cell = parent
            
        }
        
        return cell
        
    }
    
    //This delegate returns the height of a row for the outlineView.
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat
    {
        return 50
        
    }
    
    //MARK: - Custom Protocol methods
    //This delegate method passed the data from another view controller to this controller as it confirms to the custom DataCommunicator protocol.
    func sendData<T>(sendingData: T,sender:String)
    {
        
        print(sender)
        
        switch sender{
            
        case "EHire.EHAddTechnology": // adding technology
            
            let newTechnology = sendingData as! String
            let firstTechnology = EHTechnology(technology:newTechnology)
            technologyArray .append(firstTechnology)
            print(technologyArray.count)
            addTechnologyAndInterviewDateToCoreData(nil, content: newTechnology)
            sourceList.reloadData()
            
            
        case "EHire.EHPopOverController": // adding interview dates
            
            let scheduledDate = sendingData as! NSDate
            let technology = technologyArray[selectedTechnologyIndex!]
            technology.interviewDates.append(EHInterviewDate(date:scheduledDate))
            
            self.sourceList.reloadData()
            addTechnologyAndInterviewDateToCoreData(technology, content: scheduledDate)
            
        default:
            
            print("Nothing")
            
        }
        
    }
    //PRAGMAMARK: - Segue
    // This function is called automatically when a segue connection is made in the storyboard
    override  func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        print("Coming here Segue")
        
        addTechnologyController = segue.destinationController as? EHAddTechnologyController
        
        self.addTechnologyController!.delegate = self
        
    }
    
    //PRAGMAMARK: - Button Actions
    @IBAction func deleteSelectedDate(sender: NSButton)
    {
        
        
        let selectedChildCell = sender.superview as! EHInterviewDateCustomCell
        
        let selectedDate = self.sourceList.itemAtRow(self.sourceList.rowForView(selectedChildCell)) as! EHInterviewDate
        
        
        let technologyObject = self.sourceList.parentForItem(selectedDate) as! EHTechnology
        
        var count = 0
        for aInterviewDate in technologyObject.interviewDates
        {
            if selectedDate == aInterviewDate
            {
                technologyObject.interviewDates.removeAtIndex(count)
                break
            }
            count++
        }
        
        self.sourceList.reloadData()
        deleteInterviewDateFromCoreData(selectedDate)
    }
    
    
    @IBAction func deleteSelectedTechnology(sender: AnyObject)
    {
        //this if statement is added to avoid crash. To be removed once - is disabled when no technology is selected
        if self.sourceList.selectedRow == -1
        {
          return
        }
        
        let seletedTechnology = self.sourceList.itemAtRow(self.sourceList.selectedRow) as! EHTechnology
        
        technologyArray.removeAtIndex(self.sourceList.selectedRow)
        
        self.sourceList.reloadData()
        
        deleteTechnologyFromCoreData(seletedTechnology.technologyName)
    }
    
    @IBAction func addDateAction(button: NSButton)
    {
        datePopOver = NSPopover()
        
        let selectedTechView = button.superview as! EHTechnologyCustomCell
        
        
        selectedTechnologyIndex  =  getTechnologyIndex(selectedTechView)
        
        print (selectedTechnologyIndex)
        
        //Make the calendar popover go away when clicked elsewhere
        datePopOver.behavior = NSPopoverBehavior.Transient
        
        datePopOverController = self.storyboard?.instantiateControllerWithIdentifier("popover") as? EHPopOverController
        
        datePopOver.contentViewController = datePopOverController
        
        datePopOverController!.delegate = self
        
        datePopOver.showRelativeToRect(button.bounds, ofView:button, preferredEdge:NSRectEdge.MaxX)
        
        print(datePopOverController?.scheduleDatePicker.dateValue)
        
    }
    
    // This function returns the index of the selected technology
    func getTechnologyIndex(inView :EHTechnologyCustomCell) -> Int{
        var selectedIndex = 0
        let selectedTechName = inView.textField?.stringValue
        for var index = 0; index < technologyArray.count; ++index {
            
            let aTech = technologyArray[index]  as EHTechnology
            if selectedTechName == aTech.technologyName
            {
                selectedIndex = index
            }
        }
        return selectedIndex
    }
    
    //PRAGMAMARK:- Coredata
    // This method loads the saved data from Core data
    func getSourceListContent(){
        
        if let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            let context = appDelegate.managedObjectContext
            let technologyEntity = EHCoreDataHelper.createEntity("Technology", managedObjectContext: context)
            
            let records = EHCoreDataHelper.fetchRecords(nil, sortDes: nil, entity: technologyEntity!, moc: context)
            if records?.count > 0{
                
                for aRec in records!{
                    
                    let aTechnologyEntity = aRec as! Technology
                    let children = aTechnologyEntity.interviewDates
                    
                    //  mapping coredata content to our custom model
                    let technologyModel = EHTechnology(technology: aTechnologyEntity.technologyName!)
                    
                    for object in children!
                    {
                        let inDate = object as! Date
                        
                        let dateObject = EHInterviewDate(date: inDate.interviewDate!)
                        technologyModel.interviewDates.append(dateObject)
                    }
                    technologyArray.append(technologyModel)
                }
            }
            sourceList.reloadData()
            
        }
    }
    
    func addTechnologyAndInterviewDateToCoreData(sender : AnyObject?,content:AnyObject){
        
        //if the sender is nil, there is no parent. THat means a new techonlogy is being added.
        if sender == nil {
            // Adding a new technology in to coredata
            if let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate {
                let newTechnologyEntityDescription = EHCoreDataHelper.createEntity("Technology", managedObjectContext: appDelegate.managedObjectContext)
                let newTechnologyManagedObject:Technology = Technology(entity:newTechnologyEntityDescription!, insertIntoManagedObjectContext:appDelegate.managedObjectContext) as Technology
                newTechnologyManagedObject.technologyName = content as? String
                EHCoreDataHelper.saveToCoreData(newTechnologyManagedObject)
            }
            
        }
        else {
            if let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate {
                let parentTechnologyName:String = (sender?.technologyName)!
                let predicate = NSPredicate(format: "technologyName = %@",parentTechnologyName)
                let technologyRecords = EHCoreDataHelper.fetchRecordsWithPredicate(predicate, sortDes: nil, entityName: "Technology", managedObjectContext: appDelegate.managedObjectContext)
                
                let newDateEntityDescription = EHCoreDataHelper.createEntity("Date", managedObjectContext: appDelegate.managedObjectContext)
                for item in technologyRecords!
                {
                    let newDateManagedObject:Date = Date(entity:newDateEntityDescription!, insertIntoManagedObjectContext:appDelegate.managedObjectContext) as Date
                    
                    newDateManagedObject.interviewDate = content as? NSDate
                    let technology = item as! Technology
                    
                    let newDateSet = NSMutableSet(set: technology.interviewDates!)
                    newDateSet.addObject(newDateManagedObject)
                    technology.interviewDates = newDateSet
                    EHCoreDataHelper.saveToCoreData(technology)
                }
            }
        }
    }
    
    func deleteTechnologyFromCoreData(inTechnologyName:String) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        
        // deleting technology from coredata
        let predicate = NSPredicate(format: "technologyName = %@",inTechnologyName)
        let records = EHCoreDataHelper.fetchRecordsWithPredicate(predicate, sortDes: nil, entityName: "Technology", managedObjectContext: appDelegate.managedObjectContext)
        
        for record in records!{
            let aTechnology = record as! Technology
            appDelegate.managedObjectContext.deleteObject(aTechnology)
            EHCoreDataHelper.saveToCoreData(aTechnology)
        }
    }
    
    func deleteInterviewDateFromCoreData(inInterviewdate:EHInterviewDate) {
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        // creating predicate to filter the fetching result from core data
        let predicate = NSPredicate(format: "interviewDate = %@",(inInterviewdate.scheduleInterviewDate))
        
        let fetchResults =  EHCoreDataHelper.fetchRecordsWithPredicate(predicate, sortDes: nil, entityName: "Date", managedObjectContext: appDelegate.managedObjectContext)
        
        if let managedObjects = fetchResults as? [NSManagedObject] {
            for aInterviewDate in managedObjects {
                appDelegate.managedObjectContext.deleteObject(aInterviewDate)
                EHCoreDataHelper.saveToCoreData(aInterviewDate)
            }
        }
    }
    
    func showFeedbackViewController(){
        
        print("Implement")
        
        for views in self.view.subviews{
            
            views.removeFromSuperview()
            
        }
        
        feedbackViewController = self.storyboard?.instantiateControllerWithIdentifier("feedback") as? EHFeedbackViewController
        
        self.view.addSubview((feedbackViewController?.view)!)
        
        
        
    }
    
}


