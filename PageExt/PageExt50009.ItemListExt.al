pageextension 50009 "Item List Ext." extends "Item List"
{
    layout
    {
        // Add changes to page layout here
        addafter(Type)
        {
            field("Expiration Inventory"; Rec."Expiration Inventory")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addfirst(PeriodicActivities)
        {
            group(eCommerce)
            {
                CaptionML = ENU = 'eCommerce', RUS = 'eCommerce';
                Image = SuggestCustomerPayments;

                action(FilterByGroup)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Filter By Group', RUS = 'Фильтр по группам';
                    Image = FilterLines;

                    trigger OnAction()
                    var
                        codTypeHelper: Codeunit "Type Helper";
                        pageItemFilterByGroup: Page "Item Filter By Group";
                        CloseAction: Action;
                        FilterText: Text;
                        FilterPageID: Integer;
                        ParameterCount: Integer;
                    begin
                        Clear(pageItemFilterByGroup);
                        pageItemFilterByGroup.LookupMode(true);
                        if pageItemFilterByGroup.RunModal() = CloseAction::LookupCancel then exit;
                        FilterText := pageItemFilterByGroup.GetFilterItems(ParameterCount);
                        if FilterText = '' then begin
                            Rec.FilterGroup(0);
                            Rec.SetRange("No.");
                            exit;
                        end;

                        if ParameterCount < codTypeHelper.GetMaxNumberOfParametersInSQLQuery - 100 then begin
                            Rec.FilterGroup(0);
                            Rec.MarkedOnly(false);
                            Rec.SetFilter("No.", FilterText);
                        end else begin
                            // RunOnTempRec := TRUE;
                            // ClearMarks();
                            // Reset();
                        end;
                    end;
                }
                action(ClearGroupFilter)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Clear Group Filter', RUS = 'Очистить фильтр по группам';
                    Image = ClearFilter;

                    trigger OnAction()
                    var
                    begin
                        Rec.FilterGroup(0);
                        Rec.SetRange("No.");
                    end;
                }
                action(Send)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Send', RUS = 'Отправить';
                    Image = ShowInventoryPeriods;

                    trigger OnAction()
                    var
                        _Item: Record Item;
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _jsonItemList: JsonArray;
                        _jsonErrorItemList: JsonArray;
                        _jsonItem: JsonObject;
                        _jsonToken: JsonToken;
                        _jsonText: Text;
                        TotalCount: Integer;
                        Counter: Integer;
                        responseText: Text;
                    begin
                        CurrPage.SetSelectionFilter(_Item);

                        Counter := 0;

                        _Item.SetCurrentKey("Web Item");
                        _Item.SetRange("Web Item", true);

                        TotalCount := _Item.Count;
                        ConfigProgressBarRecord.Init(TotalCount, Counter, STRSUBSTNO(ApplyingURLMsg, _Item.TableCaption));

                        if _Item.FindSet(false, false) then
                            repeat
                                _jsonItem := ShipStationMgt.CreateJsonItemForWooComerse(_Item."No.");
                                Counter += 1;
                                if _jsonItem.Get('SKU', _jsonToken) then begin
                                    _jsonItemList.Add(_jsonItem);

                                    ConfigProgressBarRecord.Update(STRSUBSTNO(RecordsXofYMsg, Counter, TotalCount));

                                    if ((Counter mod 50) = 0) or (Counter = TotalCount) then begin
                                        _jsonItemList.WriteTo(_jsonText);

                                        IsSuccessStatusCode := true;
                                        ShipStationMgt.Connector2eShop(_jsonText, IsSuccessStatusCode, responseText, 'ADDPRODUCT2ESHOP');
                                        if not IsSuccessStatusCode then begin
                                            _jsonErrorItemList.Add(_jsonItem);
                                            _jsonItem.ReadFrom(responseText);
                                            _jsonErrorItemList.Add(_jsonItem);
                                        end;
                                        Clear(_jsonItemList);
                                    end;
                                end;
                            until _Item.Next() = 0;
                        ConfigProgressBarRecord.Close;
                        if _jsonErrorItemList.Count > 0 then begin
                            _jsonErrorItemList.WriteTo(_jsonText);
                            CaptionMgt.SaveStreamToFile(_jsonText, 'errorItemList.txt');
                            Message(msgSentWithError);
                        end else
                            Message(msgSentOk);
                    end;
                }
                action(SendAll)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Send All', RUS = 'Отправить все';
                    Image = SuggestVendorPayments;

                    trigger OnAction()
                    var
                        _Item: Record Item;
                        _ItemModify: Record Item;
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _jsonItemList: JsonArray;
                        _jsonErrorItemList: JsonArray;
                        _jsonItem: JsonObject;
                        _jsonToken: JsonToken;
                        _jsonText: Text;
                        TotalCount: Integer;
                        Counter: Integer;
                        msgClearTransferFlag: TextConst ENU = 'Clear Transfer Flag?', RUS = 'Очистить признак передачи?';
                        responseText: Text;
                    begin
                        if GuiAllowed then begin
                            _Item.SetCurrentKey("Transfered to eShop");
                            _Item.SetRange("Transfered to eShop", true);
                            if _Item.FindFirst() then
                                if Confirm(msgClearTransferFlag, false) then begin
                                    _Item.SetRange("Transfered to eShop", true);
                                    _Item.ModifyAll("Transfered to eShop", false);
                                end;
                            _Item.SetRange("Transfered to eShop", false);
                        end;

                        Counter := 0;

                        _Item.SetCurrentKey("Web Item");
                        _Item.SetRange("Web Item", true);
                        TotalCount := _Item.Count;

                        ConfigProgressBarRecord.Init(TotalCount, Counter, STRSUBSTNO(ApplyingURLMsg, _Item.TableCaption));

                        if _Item.FindSet(false, false) then
                            repeat
                                _jsonItem := ShipStationMgt.CreateJsonItemForWooComerse(_Item."No.");
                                Counter += 1;

                                if _jsonItem.Get('SKU', _jsonToken) then begin
                                    _jsonItemList.Add(_jsonItem);

                                    ConfigProgressBarRecord.Update(STRSUBSTNO(RecordsXofYMsg, Counter, TotalCount));

                                    if ((Counter mod 50) = 0) or (Counter = TotalCount) then begin
                                        _jsonItemList.WriteTo(_jsonText);

                                        IsSuccessStatusCode := true;
                                        ShipStationMgt.Connector2eShop(_jsonText, IsSuccessStatusCode, responseText, 'ADDPRODUCT2ESHOP');
                                        if not IsSuccessStatusCode then begin
                                            _jsonErrorItemList.Add(_jsonItem);
                                            _jsonItem.ReadFrom(responseText);
                                            _jsonErrorItemList.Add(_jsonItem);
                                        end;
                                        Clear(_jsonItemList);
                                        Commit();
                                    end;
                                    _ItemModify.Get(_Item."No.");
                                    _ItemModify."Transfered to eShop" := true;
                                    _ItemModify.Modify();
                                end;
                            until _Item.Next() = 0;
                        ConfigProgressBarRecord.Close;
                        if _jsonErrorItemList.Count > 0 then begin
                            _jsonErrorItemList.WriteTo(_jsonText);
                            CaptionMgt.SaveStreamToFile(_jsonText, 'errorItemList.txt');
                            Message(msgSentWithError);
                        end else
                            Message(msgSentOk);

                        _Item.Reset();
                        _Item.SetCurrentKey("Transfered to eShop");
                        _Item.SetRange("Transfered to eShop", true);
                        _Item.ModifyAll("Transfered to eShop", false);
                    end;
                }
                action(Send2File)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Send to File', RUS = 'Отправить в файл';
                    Image = SuggestField;

                    trigger OnAction()
                    var
                        _Item: Record Item;
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _jsonItemList: JsonArray;
                        _jsonItem: JsonObject;
                        _jsonToken: JsonToken;
                        _jsonText: Text;
                        TotalCount: Integer;
                        Counter: Integer;
                    begin
                        CurrPage.SetSelectionFilter(_Item);

                        Counter := 0;

                        _Item.SetCurrentKey("Web Item");
                        _Item.SetRange("Web Item", true);
                        TotalCount := _Item.Count;

                        ConfigProgressBarRecord.Init(TotalCount, Counter, STRSUBSTNO(ApplyingURLMsg, _Item.TableCaption));

                        if _Item.FindSet(false, false) then
                            repeat
                                _jsonItem := ShipStationMgt.CreateJsonItemForWooComerse(_Item."No.");
                                if _jsonItem.Get('SKU', _jsonToken) then
                                    _jsonItemList.Add(_jsonItem);

                                ConfigProgressBarRecord.Update(STRSUBSTNO(RecordsXofYMsg, Counter, TotalCount));
                                Counter += 1;
                            until _Item.Next() = 0;
                        ConfigProgressBarRecord.Close;
                        _jsonItemList.WriteTo(_jsonText);
                        CaptionMgt.SaveStreamToFile(_jsonText, 'selectedItemList.txt');
                    end;
                }
                action(SendAll2File)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Send All to File', RUS = 'Отправить все в файл';
                    Image = SuggestFinancialCharge;

                    trigger OnAction()
                    var
                        _Item: Record Item;
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _jsonItemList: JsonArray;
                        _jsonItem: JsonObject;
                        _jsonToken: JsonToken;
                        _jsonText: Text;
                        TotalCount: Integer;
                        Counter: Integer;
                    begin
                        Counter := 0;

                        _Item.SetCurrentKey("Web Item");
                        _Item.SetRange("Web Item", true);
                        TotalCount := _Item.Count;

                        ConfigProgressBarRecord.Init(TotalCount, Counter, STRSUBSTNO(ApplyingURLMsg, _Item.TableCaption));

                        if _Item.FindSet(false, false) then
                            repeat
                                _jsonItem := ShipStationMgt.CreateJsonItemForWooComerse(_Item."No.");
                                if _jsonItem.Get('SKU', _jsonToken) then
                                    _jsonItemList.Add(_jsonItem);

                                ConfigProgressBarRecord.Update(STRSUBSTNO(RecordsXofYMsg, Counter, TotalCount));
                                Counter += 1;
                            until _Item.Next() = 0;
                        ConfigProgressBarRecord.Close;
                        _jsonItemList.WriteTo(_jsonText);
                        CaptionMgt.SaveStreamToFile(_jsonText, 'allItemList.txt');
                    end;
                }
            }
        }
    }

    var
        RecordsXofYMsg: TextConst ENU = 'Records: %1 of %2', RUS = 'Запись: %1 из %2';
        ApplyingURLMsg: TextConst ENU = 'Sending Table %1', RUS = 'Пересылается таблица %1';
        msgSentOk: TextConst ENU = 'Sent into eShop is Ok!', RUS = 'Отправлено в eShop!';
        msgSentWithError: TextConst ENU = 'Sent into eShop with Errors!', RUS = 'Отправлено в eShop с ошибками!';
        ConfigProgressBarRecord: Codeunit "Config Progress Bar";
        CaptionMgt: Codeunit "Caption Mgt.";
        IsSuccessStatusCode: Boolean;
}