# MSOHelper
Helper classes for MS Office 365 iOS SDK

Office 365 SDK for iOS: https://github.com/OfficeDev/Office-365-SDK-for-iOS

The files in this repository are created over the above SDK as helper classes to allow easy integration of Office 365 in your project.

Currently the version has helper classes for performing CRUD operations on 'Contacts' using the SDK.

For complete iOS project:
https://github.com/vsubrahmanian/office365Demo

----------------------------------------
Project Implementation Details:
----------------------------------------
In this project I have created a MSOContactHelper class that will handle the interaction with Office365 SDK for OAuth and OData fething. The formatiing of the request and parsing of the response for getting contacts from sharepoint server is also handled in this class.

MSOContactInfoModel is a model created that will manage all the contact details. It has properties for each of the contact fields and corresponds to NSCopying and NSCoding protocols for copying or saving data to disk.


- identifier : This is the key in the Sharepoint contact db table
- key : This is the name of the property used to identify the item in the model (MSOContactInfoModel)
- type : this defines if the cell is a textField or textView (Currently the cell is configured to support only the below types)
- title : this is the (to be localised) text for displaying the title on the cell
- sectionTitle : this is the (to be localised) text for displaying the section title for the field.
- placeholder : this is the placeholder text for textfields.
- cellHeight : This is the cell height to be used for the field.

For complete iOS project:
https://github.com/vsubrahmanian/office365Demo

This project is made available for free under Apache License version 2.0.
Check out the LICENSE document file for the "Terms of Use". 
---