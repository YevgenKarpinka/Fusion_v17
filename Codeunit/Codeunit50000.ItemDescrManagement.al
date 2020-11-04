codeunit 50000 "Item Descr. Management"
{
    EventSubscriberInstance = StaticAutomatic;
    Permissions = tabledata "Config. Package" = rimd, tabledata "Excel Buffer" = rimd,
    tabledata "Item Description" = rimd, tabledata Item = r;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure DeleteItemDescription(var Rec: Record Item; RunTrigger: Boolean)
    var
        locItemDescription: Record "Item Description";
    begin
        locItemDescription.SetRange("Item No.", Rec."No.");
        locItemDescription.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, 370, 'OnBeforeParseCellValue', '', true, true)]
    local procedure ParseCellValue2Blob(var ExcelBuffer: Record "Excel Buffer"; var Value: Text; var FormatString: Text; var isHandled: Boolean)
    var
        _OutStream: OutStream;
    begin
        Clear(ExcelBuffer."Cell Value as Blob");
        if StrLen(Value) <= MaxStrLen(ExcelBuffer."Cell Value as Text") then exit;

        ExcelBuffer."Cell Value as Blob".CreateOutStream(_OutStream, TextEncoding::UTF8);
        _OutStream.WriteText(Value);
        isHandled := true;
    end;

    // [EventSubscriber(ObjectType::Table, 370, 'OnAfterAddColumnToBuffer', '', true, true)]
    // local procedure FillBlobField(VAR ExcelBuffer: Record "Excel Buffer"; Value: Variant; IsFormula: Boolean; CommentText: Text; IsBold: Boolean; IsItalics: Boolean; IsUnderline: Boolean; NumFormat: Text)
    // var
    //     TempBlob: Record TempBlob temporary;
    // begin
    //     if StrLen(Value) <= MaxStrLen(ExcelBuffer."Cell Value as Text") then exit;

    //     TempBlob.Blob := Value;
    //     TempBlob.WriteAsText(Value, TEXTENCODING::UTF8);
    //     ExcelBuffer."Cell Value as Blob" := TempBlob.Blob;
    //     ExcelBuffer.Modify();
    // end;

    procedure Export2JSON(_ConfPackTable: Record "Config. Package Table"): Text
    var
        _ConfPack: Record "Config. Package";
        _toFile: Text[250];
        _jsonPackage: JsonArray;
        _TempBlob: Codeunit "Temp Blob";
        _OutStream: OutStream;
        _jsonText: Text;
    begin
        _ConfPackTable.FindFirst();
        _ConfPack.Get(_ConfPackTable."Package Code");
        _ConfPack.TestField(Code);
        _ConfPack.TestField("Package Name");
        if _toFile = '' then
            _toFile := StrSubstNo(PackageFileNameTxt, _ConfPack.Code);

        ExportPackageJSONObject(_jsonPackage, _ConfPackTable, _ConfPack);

        _jsonPackage.WriteTo(_jsonText);

        exit(_jsonText);

        _TempBlob.CreateOutStream(_OutStream, TextEncoding::UTF8);
        _OutStream.WriteText(_jsonText);

        fileMgt.BLOBExport(_TempBlob, _toFile, true);
    end;

    local procedure ExportPackageJSONObject(var _jsonPackage: JsonArray; var _ConfPackTable: Record "Config. Package Table"; _ConfPack: Record "Config. Package");
    var
        _jsonConfPack: JsonObject;
        _jsonConfPackTable: JsonObject;
        _jsonConfPackTableList: JsonObject;
        txtList: TextConst ENU = '%1List', RUS = '%1Список';
    begin
        _ConfPack.TestField(Code);
        _ConfPack.TestField("Package Name");

        _jsonConfPack.Add(_ConfPack.FieldName("Package Name"), _ConfPack."Package Name");
        _jsonConfPack.Add(_ConfPack.FieldName(Code), _ConfPack.Code);
        if _ConfPack."Language ID" > 0 then
            _jsonConfPack.Add(_ConfPack.FieldName("Language ID"), Format(_ConfPack."Language ID"));
        _jsonConfPack.Add(_ConfPack.FieldName("Product Version"), _ConfPack."Product Version");
        if _ConfPack."Processing Order" > 0 then
            _jsonConfPack.Add(_ConfPack.FieldName("Processing Order"), Format(_ConfPack."Processing Order"));
        if _ConfPack."Exclude Config. Tables" then
            _jsonConfPack.Add(_ConfPack.FieldName("Exclude Config. Tables"), '1');

        _jsonPackage.Add(_jsonConfPack);

        if GuiAllowed then
            ConfigProgressBar.Init(_ConfPackTable.Count, 1, ExportPackageTxt);

        _ConfPackTable.SetAutoCalcFields("Table Name");

        _ConfPackTable.SetRange("Package Code", _ConfPack.Code);
        if _ConfPackTable.FindSet(false, false) then
            repeat
                if GuiAllowed then
                    ConfigProgressBar.Update(_ConfPackTable."Table Name");
                Clear(_jsonConfPackTable);
                _jsonConfPackTable.Add(_ConfPackTable.FieldCaption("Table ID"), _ConfPackTable."Table ID");
                _jsonConfPackTable.Add(_ConfPackTable.FieldCaption("Table Name"), ExportConfigPackageTable2JSON(_ConfPackTable));
                _jsonConfPackTableList.Add(StrSubstNo(txtList, _ConfPackTable."Table Name"), ExportConfigPackageTable2JSON(_ConfPackTable));
            until _ConfPackTable.Next() = 0;

        Clear(_jsonPackage);
        _jsonPackage.Add(_jsonConfPack);
    end;

    local procedure ExportConfigPackageTable2JSON(_ConfPackTable: Record "Config. Package Table"): JsonArray
    var
        jsonConfPackTableField: JsonArray;
    begin
        // to do
        jsonConfPackTableField.Add('[]');
        exit(jsonConfPackTableField);
    end;

    procedure ExportExcelSheet()
    var
        ItemDescr: Record "Item Description";
        FileName: Text;
        FileManagement: Codeunit "File Management";
        ExcelStream: InStream;
        Rows: Integer;
        Columns: Integer;
        RowNo: Integer;
        ColumnNo: Integer;
    begin
        FileName := '';
        UploadIntoStream(ImportTitleTxt, '', FileManagement.GetToFilterText('', ExcelFileNameTxt), FileName, ExcelStream);
        if FileName = '' then exit;
        ExcelBuffer.OpenBookStream(ExcelStream, ItemDescr.TableCaption);
        ExcelBuffer.ReadSheet;
        Rows := ItemDescr.Count;
        if GuiAllowed then
            Window.Open(StrSubstNo(txtDialog, ItemDescr.TableCaption) + txtProgressBar);
        if ItemDescr.FindSet(false, false) then
            repeat
                ExcelBuffer.AddColumn(ItemDescr."Item No.", false, '', false, false, false, '@', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(ItemDescr.GetTextFromBlobField(ItemDescr.FieldNo(Description)), false, '', false, false, false, '@', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(ItemDescr.GetTextFromBlobField(ItemDescr.FieldNo(Description)), false, '', false, false, false, '@', ExcelBuffer."Cell Type"::Text);
                // ItemDescr.SetBulletPoint1(GetValueAtCell(RowNo, 3));
                // ItemDescr.SetBulletPoint2(GetValueAtCell(RowNo, 4));
                // ItemDescr.SetBulletPoint3(GetValueAtCell(RowNo, 5));
                // ItemDescr.SetBulletPoint4(GetValueAtCell(RowNo, 6));
                // ItemDescr."Bullet Point 5" := GetValueAtCell(RowNo, 7);
                // ItemDescr."Main Image URL" := GetValueAtCell(RowNo, 8);
                // ItemDescr."Other Image URL" := GetValueAtCell(RowNo, 9);
                // ItemDescr."Label Image URL" := GetValueAtCell(RowNo, 10);
                // ItemDescr."Label Image URL 2" := GetValueAtCell(RowNo, 11);
                // ItemDescr.SetSearchTerms(GetValueAtCell(RowNo, 12));
                // ItemDescr.SetSearchTermsForGoogleOnly(GetValueAtCell(RowNo, 13));
                // ItemDescr.SetIngredients(GetValueAtCell(RowNo, 14));
                // ItemDescr.SetIndications(GetValueAtCell(RowNo, 15));
                // ItemDescr.SetDirections(GetValueAtCell(RowNo, 16));
                // ItemDescr.SetWarning(GetValueAtCell(RowNo, 17));
                // ItemDescr."Name RU" := GetValueAtCell(RowNo, 18);
                // ItemDescr."Name RU 2" := GetValueAtCell(RowNo, 19);
                // ItemDescr.SetDescriptionRU(GetValueAtCell(RowNo, 20));
                // ItemDescr.SetBulletPoint1RU(GetValueAtCell(RowNo, 21));
                // ItemDescr.SetBulletPoint2RU(GetValueAtCell(RowNo, 22));
                // ItemDescr.SetBulletPoint3RU(GetValueAtCell(RowNo, 23));
                // ItemDescr.SetBulletPoint4RU(GetValueAtCell(RowNo, 24));
                // ItemDescr."Bullet Point 5 RU" := GetValueAtCell(RowNo, 25);
                // ItemDescr.SetIngredientsRU(GetValueAtCell(RowNo, 26));
                // ItemDescr.SetIndicationsRU(GetValueAtCell(RowNo, 27));
                // ItemDescr.SetDirectionsRU(GetValueAtCell(RowNo, 28));
                // Evaluate(ItemDescr.New, GetValueAtCell(RowNo, 29));
                // Evaluate(ItemDescr."Sell-out", GetValueAtCell(RowNo, 30));
                // ItemDescr.Barcode := GetValueAtCell(RowNo, 31);
                // if ItemDescr.Insert() then ItemDescr.Modify();

                if GuiAllowed then
                    Window.Update(1, RowNo / Rows * 10000);
            until ItemDescr.Next() = 0;

        ExcelBuffer.WriteSheet(ItemDescr.TableCaption, CompanyName, UserId);
        ExcelBuffer.CloseBook;

        if GuiAllowed then
            Window.Close();
    end;

    procedure ImportExcelSheet()
    var
        ItemDescr: Record "Item Description";
        FileName: Text;
        FileManagement: Codeunit "File Management";
        ExcelStream: InStream;
        Rows: Integer;
        Columns: Integer;
        RowNo: Integer;
        ColumnNo: Integer;
    begin
        FileName := '';
        UploadIntoStream(ImportTitleTxt, '', FileManagement.GetToFilterText('', ExcelFileNameTxt), FileName, ExcelStream);
        if FileName = '' then exit;
        ExcelBuffer.OpenBookStream(ExcelStream, ItemDescr.TableCaption);
        ExcelBuffer.ReadSheet;
        if ExcelBuffer.FindLast then;
        Rows := ExcelBuffer."Row No.";
        Columns := ExcelBuffer."Column No.";
        if (Rows < 4) or (Columns < 29) then Error(WrongFormatExcelFileErr);
        if GuiAllowed then
            ConfigProgressBarRecord.Init(Rows, RowNo, STRSUBSTNO(ApplyingURLMsg, ItemDescr.TableCaption));
        // Window.Open(StrSubstNo(txtDialog, ItemDescr.TableCaption) + txtProgressBar);
        for RowNo := 4 to Rows do begin
            ItemDescr."Item No." := GetValueAtCell(RowNo, 1);
            if ItemDescr.Insert() then ItemDescr.Modify();

            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo(Description), GetValueAtCell(RowNo, 2));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 1"), GetValueAtCell(RowNo, 3));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 2"), GetValueAtCell(RowNo, 4));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 3"), GetValueAtCell(RowNo, 5));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 4"), GetValueAtCell(RowNo, 6));
            ItemDescr."Bullet Point 5" := GetValueAtCell(RowNo, 7);
            ItemDescr."Main Image URL" := GetValueAtCell(RowNo, 8);
            ItemDescr."Other Image URL" := GetValueAtCell(RowNo, 9);
            ItemDescr."Label Image URL" := GetValueAtCell(RowNo, 10);
            ItemDescr."Label Image URL 2" := GetValueAtCell(RowNo, 11);
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Search Terms"), GetValueAtCell(RowNo, 12));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Search Terms for Google only"), GetValueAtCell(RowNo, 13));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo(Ingredients), GetValueAtCell(RowNo, 14));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo(Indications), GetValueAtCell(RowNo, 15));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo(Directions), GetValueAtCell(RowNo, 16));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo(Warning), GetValueAtCell(RowNo, 17));
            ItemDescr."Name RU" := GetValueAtCell(RowNo, 18);
            ItemDescr."Name RU 2" := GetValueAtCell(RowNo, 19);
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Description RU"), GetValueAtCell(RowNo, 20));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 1 RU"), GetValueAtCell(RowNo, 21));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 2 RU"), GetValueAtCell(RowNo, 22));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 3 RU"), GetValueAtCell(RowNo, 23));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Bullet Point 4 RU"), GetValueAtCell(RowNo, 24));
            ItemDescr."Bullet Point 5 RU" := GetValueAtCell(RowNo, 25);
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Ingredients RU"), GetValueAtCell(RowNo, 26));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Indications RU"), GetValueAtCell(RowNo, 27));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Directions RU"), GetValueAtCell(RowNo, 28));
            Evaluate(ItemDescr.New, GetValueAtCell(RowNo, 29));
            Evaluate(ItemDescr."Sell-out", GetValueAtCell(RowNo, 30));
            Evaluate(ItemDescr.Barcode, GetValueAtCell(RowNo, 31));
            Evaluate(ItemDescr."Unit Count Net", GetValueAtCell(RowNo, 32));
            Evaluate(ItemDescr."Unit Count Type", GetValueAtCell(RowNo, 33));
            Evaluate(ItemDescr."FDA Code", GetValueAtCell(RowNo, 34));
            Evaluate(ItemDescr."HTS Code", GetValueAtCell(RowNo, 35));
            Evaluate(ItemDescr."Product Type", GetValueAtCell(RowNo, 36));
            Evaluate(ItemDescr."Item Type Keyword", GetValueAtCell(RowNo, 37));
            Evaluate(ItemDescr."Package Quantity", GetValueAtCell(RowNo, 38));
            Evaluate(ItemDescr."Serving Size", GetValueAtCell(RowNo, 39));
            Evaluate(ItemDescr."Servings per container", GetValueAtCell(RowNo, 40));
            ItemDescr.SetTextToBlobField(ItemDescr.FieldNo("Legal Disclaimer"), GetValueAtCell(RowNo, 41));
            ItemDescr."Name ENG" := GetValueAtCell(RowNo, 42);
            ItemDescr."Name ENG 2" := GetValueAtCell(RowNo, 43);

            ItemDescr.Modify();

            if GuiAllowed then
                ConfigProgressBarRecord.Update(STRSUBSTNO(RecordsXofYMsg, RowNo, Rows));
            // Window.Update(1, RowNo - 3);
        end;
        ExcelBuffer.CloseBook;

        if GuiAllowed then
            ConfigProgressBarRecord.Close;
        // Window.Close();
    end;

    procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text;
    var
        _InStream: InStream;
        TypeHelper: Codeunit "Type Helper";
        CR: Text[1];
    begin
        if not ExcelBuffer.Get(RowNo, ColNo) then exit('');
        if not ExcelBuffer."Cell Value as Blob".HasValue then exit(ExcelBuffer."Cell Value as Text");

        ExcelBuffer.CALCFIELDS("Cell Value as Blob");
        CR[1] := 10;
        ExcelBuffer."Cell Value as Blob".CreateInStream(_InStream, TextEncoding::UTF8);
        EXIT(TypeHelper.ReadAsTextWithSeparator(_InStream, CR));
    end;

    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ImportTitleTxt: Label 'Choose the Excel worksheet where data classifications have been added.';
        ExcelFileNameTxt: Label '*.xlsx';
        WrongFormatExcelFileErr: Label 'Looks like the Excel worksheet you provided is not formatted correctly.';
        Window: Dialog;
        txtDialog: TextConst ENU = 'Importing Data from Excel to %1\', RUS = 'Импортуруються Данные с Excel в %1\';
        txtProgressBar: TextConst ENU = '#1##################', RUS = '#1##################';
        fileMgt: Codeunit "File Management";
        ConfigProgressBar: Codeunit "Config. Progress Bar";
        PackageFileNameTxt: Label 'json%1.json', Locked = true;
        ExportPackageTxt: Label 'Exporting package';
        ConfigProgressBarRecord: Codeunit "Config Progress Bar";
        RecordsXofYMsg: TextConst ENU = 'Records: %1 of %2', RUS = 'Запись: %1 из %2';
        ApplyingURLMsg: TextConst ENU = 'Import from Excel to Table %1', RUS = 'Импортируется с Excel в таблицу %1';
}