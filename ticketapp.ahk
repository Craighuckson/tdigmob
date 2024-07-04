GetTxtFilesInFolder(folderPath) {
    FileList := "" ; Initialize an empty string to hold the list of .txt files
    Loop, Files, % folderPath "\*.txt", R, F ; Loop through all .txt files in the specified folder and its subfolders
    {
        FileList .= A_LoopFileFullPath . "`n" ; Append the full path of the current .txt file to the list
    }
    return FileList ; Return the list of .txt files
}

;folderPath := "C:\Users\craig\AppData\Local\TelDigFusion.Data\data" ; Replace with your actual folder path
;txtFiles := GetTxtFilesInFolder(folderPath)
;MsgBox % txtFiles ; Display a message box with the list of .txt files

ExtractDataFromTxtFile(txtFilePath) {
    FileRead, fileContent, % txtFilePath ; Read the content of the text file

    data := {} ; Initialize an empty associative array to hold the extracted data

    ; Use a regular expression to extract the ticket number, region, and city
    RegExMatch(fileContent, "s)UR_ID_REQUE::(.*?)(\r\n|$)", ticketNumber)
    RegExMatch(fileContent, "s)UR_NOM_TESSE_2::(.*?)(\r\n|$)", region)
    RegExMatch(fileContent, "s)UR_NOM_TESSE_1::(.*?)(\r\n|$)", city)
    RegExMatch(fileContent, "S)UR_NOM_ARTER_PRINC::(.*?)(\r\n|$)", street)
    RegExMatch(fileContent, "S)UR_NO_CIVIC_INITI::(.*?)(\r\n|$)", civicNumber)
    RegExMatch(fileContent, "S)UR_NOM_ARTER_INTER_1::(.*?)(\r\n|$)", intersection1)
    RegExMatch(fileContent, "S)UR_NOM_ARTER_INTER_2::(.*?)(\r\n|$)", intersection2)
    RegExMatch(fileContent, "S)UA_STATI_CODE::(.*?)(\r\n|$)", utility)
    RegExMatch(fileContent, "S)UR_EXCAV_NOM::(.*?)(\r\n|$)", contractor)
    RegExMatch(fileContent, "S)UR_COMME::(.*?)(\r\n|$)", workingFor)
    RegExMatch(fileContent, "S)UR_TYPE_TRAVA::(.*?)(\r\n|$)", workType)
    RegExMatch(fileContent, "S)UR_REQ_D_DEBUT::(.*?)(\r\n|$)", callDate)
    RegExMatch(fileContent, "S)UR_REQ_D_TRAVA::(.*?)(\r\n|$)", workDate)



    ; Add the extracted data to the associative array
    data["ticket_number"] := ticketNumber
    data["region"] := region1
    data["city"] := city
    data["street"] := street
    data["civicNumber"] := civicNumber
    data["intersection1"] := intersection1
    data["intersection2"] := intersection2
    data["utility"] := utility
    data["contractor"] := contractor
    data["workingFor"] := workingFor
    data["workType"] := workType
    data["callDate"] := callDate
    data["workDate"] := workDate
    

    return data ; Return the associative array
}

txtFilePath := "C:\Users\craig\AppData\Local\TelDigFusion.Data\data\3299122_ROGYRK01\2539145.TXT" ; Replace with your actual text file path
data := ExtractDataFromTxtFile(txtFilePath)
MsgBox % "Ticket Number: " data["ticket_number"] "`nRegion: " data["region"] "`nCity: " data["city"]