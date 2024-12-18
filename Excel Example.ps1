$ExcelObject = new-Object -comobject Excel.Application 
$ExcelObject.visible = $false 
$ExcelObject.DisplayAlerts =$false
$date= get-date -format "yyyyMMddHHss"
$strPath1="C:\PshoutPut\Active_Users_$date.xlsx" 
if (Test-Path $strPath1) {  
  #Open the document  
$ActiveWorkbook = $ExcelObject.WorkBooks.Open($strPath1)  
$ActiveWorksheet = $ActiveWorkbook.Worksheets.Item(1)  
} else {  
# Create Excel file  
$ActiveWorkbook = $ExcelObject.Workbooks.Add()  
$ActiveWorksheet = $ActiveWorkbook.Worksheets.Item(1) 

#Add Headers to excel file
$ActiveWorksheet.Cells.Item(1,1) = "User_Id"  
$ActiveWorksheet.cells.item(1,2) = "User_Name" 
$ActiveWorksheet.cells.item(1,3) = "CostCenter"
$ActiveWorksheet.cells.item(1,4) = "Approving Manager"
$format = $ActiveWorksheet.UsedRange
$format.Interior.ColorIndex = 19
$format.Font.ColorIndex = 11
$format.Font.Bold = "True"
} 
#Loop through the Array and add data into the excel file created.
foreach ($line in $Activeusers){
     ($user_id,$user_name,$Costcntr,$ApprMgr) = $line.split('|')
      $introw = $ActiveWorksheet.UsedRange.Rows.Count + 1  
      $ActiveWorksheet.cells.item($introw, 1) = $user_id  
      $ActiveWorksheet.cells.item($introw, 2) = $user_name
      $ActiveWorksheet.cells.item($introw, 3) = $Costcntr
      $ActiveWorksheet.cells.item($introw, 4) = $ApprMgr 
      $ActiveWorksheet.UsedRange.EntireColumn.AutoFit();
      }