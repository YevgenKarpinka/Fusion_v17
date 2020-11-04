codeunit 50001 "ShipStation Mgt."
{
    Permissions = tabledata "Source Parameters" = rimd, tabledata "Sales Header" = rimd,
    tabledata "Sales Line" = r, tabledata "Shipping Agent Services" = rimd,
    tabledata "Shipping Agent" = rimd, tabledata Customer = r,
    tabledata Item = r, tabledata Manufacturer = r,
    tabledata Brand = r, tabledata "Item Filter Group" = r,
    tabledata "Item Category" = r,
    tabledata "Warehouse Shipment Line" = r, tabledata "Warehouse Shipment Header" = r,
    tabledata "Tenant Media" = rimd, tabledata "Document Attachment" = rimd,
    tabledata Contact = r, tabledata Location = r,
    tabledata "Company Information" = r, tabledata "Item Attribute" = r,
    tabledata "Item Attribute Value" = r, tabledata "Item Attribute Value Mapping" = r;

    trigger OnRun()
    begin

    end;

    procedure CalculateSalesOrderGrossWeight(OrderNo: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
        positionGrossWeight: Decimal;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", OrderNo);
        if SalesLine.FindSet() then
            repeat
                positionGrossWeight += SalesLine.Quantity * SalesLine."Gross Weight";
            until SalesLine.Next() = 0;
        exit(positionGrossWeight);
    end;

    procedure SentOrderShipmentStatusForWooComerse(_salesOrderNo: Code[20]; locShippedStatus: Integer)
    var
        _jsonOrderShipmentStatus: JsonObject;
        _jsonToken: JsonToken;
        _jsonText: Text;
        responseText: Text;
        IsSuccessStatusCode: Boolean;
        _captionMgt: Codeunit "Caption Mgt.";
    begin
        GetShipStationSetup();
        if not glShipStationSetup."Order Status Update" then exit;

        _jsonOrderShipmentStatus := CreateJsonOrderShipmentStatusForWooComerse(_salesOrderNo, locShippedStatus);
        if not _jsonOrderShipmentStatus.Get('id', _jsonToken) then exit;
        _jsonOrderShipmentStatus.WriteTo(_jsonText);

        IsSuccessStatusCode := true;
        Connector2eShop(_jsonText, IsSuccessStatusCode, responseText, 'SENTDELIVERYSTATUS2ESHOP');
        if not IsSuccessStatusCode then begin
            _captionMgt.SaveStreamToFile(responseText, 'errorItemList.txt');
        end;
    end;

    local procedure CreateJsonOrderShipmentStatusForWooComerse(_salesOrderNo: Code[20]; locShippedStatus: Integer): JsonObject
    var
        _salerHeader: Record "Sales Header";
        _jsonObject: JsonObject;
        _jsonNullArray: JsonArray;
        _iCExtended: Codeunit "IC Extended";
        _orderNo: Code[20];
        _postedOrderNo: Code[20];
    begin
        // _iCExtended.FoundPurchaseOrder(_salesOrderNo, _orderNo, _postedOrderNo);
        // if (_orderNo = '') and (_postedOrderNo = '') then begin
        //     _jsonObject.Add('id', _salesOrderNo);
        //     _jsonObject.Add('status', _shippedStatus);
        //     _jsonObject.Add('trackId', _jsonTrackIdFromSalesOreder(_salesOrderNo));
        // end else begin
        //     _iCExtended.FoundParentICSalesOrder(_salesOrderNo, _orderNo);
        //     if _orderNo <> '' then begin
        //         _jsonObject.Add('id', _salesOrderNo);
        //         _jsonObject.Add('status', _shippedStatus);
        //         _jsonObject.Add('trackId', _jsonNullArray);
        //     end;
        // end;
        _jsonObject.Add('id', _salesOrderNo);
        // _jsonObject.Add('status', _shippedStatus);
        if locShippedStatus = 0 then begin
            _jsonObject.Add('status', _assemblededStatus);
            _jsonObject.Add('trackId', _jsonNullArray);
        end else begin
            _jsonObject.Add('status', _shippedStatus);
            _jsonObject.Add('trackId', _jsonTrackIdFromSalesOreder(_salesOrderNo));
        end;

        exit(_jsonObject);
    end;

    local procedure _jsonTrackIdFromSalesOreder(_salesOrderNo: Code[20]): JsonArray
    var
        _salerHeader: Record "Sales Header";
        _jsonArray: JsonArray;
    begin
        if _salerHeader.Get(_salerHeader."Document Type"::Order, _salesOrderNo) then
            if _salerHeader."Package Tracking No." <> '' then
                _jsonArray.Add(_salerHeader."Package Tracking No.");
        exit(_jsonArray);
    end;

    procedure SetTestMode(_testMode: Boolean)
    begin
        testMode := _testMode;
    end;

    procedure Connect2eShop(SPCode: Code[20]; Body2Request: Text; newURL: Text; var IsSuccessStatusCode: Boolean): Text
    var
        SourceParameters: Record "Source Parameters";
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Client: HttpClient;
        responseText: Text;
        Autorization: Text;
        jsonLogin: JsonObject;
    begin
        SourceParameters.Get(SPCode);

        RequestMessage.Method := Format(SourceParameters."FSp RestMethod");
        if newURL = '' then
            newURL := SourceParameters."FSp URL"
        else
            newURL := StrSubstNo('%1%2', SourceParameters."FSp URL", newURL);

        RequestMessage.SetRequestUri(newURL);
        RequestMessage.GetHeaders(Headers);

        if SourceParameters."FSp RestMethod" = SourceParameters."FSp RestMethod"::POST then begin
            if SPCode = 'LOGIN2ESHOP' then begin
                // Autorization := StrSubstNo('%1=%2&%3=%4', 'email', SourceParameters."FSp UserName", 'password', SourceParameters."FSp Password");
                // Body2Request := Autorization;
                jsonLogin.Add('email', SourceParameters."FSp UserName");
                jsonLogin.Add('password', SourceParameters."FSp Password");
                jsonLogin.WriteTo(Body2Request);
            end;
            RequestMessage.Content.WriteFrom(Body2Request);
            RequestMessage.Content.GetHeaders(Headers);
            if SourceParameters."FSp ContentType" <> 0 then begin
                Headers.Remove('Content-Type');
                Headers.Add('Content-Type', Format(SourceParameters."FSp ContentType"));
            end;
        end;

        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(responseText);
        IsSuccessStatusCode := ResponseMessage.IsSuccessStatusCode();

        // Insert Operation to Log
        InsertOperationToLog('ESHOP', Format(SourceParameters."FSp RestMethod"), newURL, Autorization, Body2Request, responseText, IsSuccessStatusCode);

        exit(responseText);
    end;

    procedure Connector2eShop(Body2Request: Text; var IsSuccessStatusCode: Boolean; var responseText: Text; SPCode: Code[20])
    begin
        if globalToken = '' then begin
            // get to endpoint GetToken
            firstToken := DelChr(Connect2eShop('GETTOKEN', '', '', IsSuccessStatusCode), '<>', '"');
            globalToken := DelChr(Connect2eShop('LOGIN2ESHOP', '', firstToken, IsSuccessStatusCode), '<>', '"');
        end;
        if not IsSuccessStatusCode then begin
            responseText := globalToken;
            exit;
        end;
        // responseText := Connect2eShop('ADDPRODUCT2ESHOP', Body2Request, globalToken, IsSuccessStatusCode);
        responseText := Connect2eShop(SPCode, Body2Request, globalToken, IsSuccessStatusCode);
    end;

    procedure Connect2ShipStation(SPCode: Integer; Body2Request: Text; newURL: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        SourceParameters: Record "Source Parameters";
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Client: HttpClient;
        responseText: Text;
        JSObject: JsonObject;
        errMessage: Text;
        errExceptionMessage: Text;
        _InStream: InStream;
        _OutStream: OutStream;
        Autorization: Text;
    begin
        SourceParameters.SetCurrentKey("FSp Event");
        SourceParameters.SetRange("FSp Event", SPCode);
        SourceParameters.FindFirst();

        if newURL = '' then
            newURL := SourceParameters."FSp URL"
        else
            newURL := StrSubstNo('%1%2', SourceParameters."FSp URL", newURL);

        RequestMessage.Method := Format(SourceParameters."FSp RestMethod");
        RequestMessage.SetRequestUri(newURL);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', SourceParameters."FSp Accept");
        if (SourceParameters."FSp AuthorizationFrameworkType" = SourceParameters."FSp AuthorizationFrameworkType"::OAuth2)
            and (SourceParameters."FSp AuthorizationToken" <> '') then begin
            Headers.Add('Authorization', SourceParameters."FSp AuthorizationToken");
        end else
            if SourceParameters."FSp UserName" <> '' then begin
                Autorization := StrSubstNo('Basic %1',
                            Base64Convert.ToBase64(StrSubstNo('%1:%2', SourceParameters."FSp UserName", SourceParameters."FSp Password")));
                Headers.Add('Authorization', Autorization);
            end;

        Headers.Add('If-Match', SourceParameters."FSp ETag");

        if SourceParameters."FSp RestMethod" = SourceParameters."FSp RestMethod"::POST then begin
            RequestMessage.Content.WriteFrom(Body2Request);
            RequestMessage.Content.GetHeaders(Headers);
            if SourceParameters."FSp ContentType" <> 0 then begin
                Headers.Remove('Content-Type');
                Headers.Add('Content-Type', Format(SourceParameters."FSp ContentType"));
            end;
        end;

        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(responseText);

        // Insert Operation to Log
        InsertOperationToLog('SSTATION', Format(SourceParameters."FSp RestMethod"), newURL, Autorization, Body2Request, responseText, ResponseMessage.IsSuccessStatusCode());

        GetShipStationSetup();
        If not ResponseMessage.IsSuccessStatusCode() and glShipStationSetup."Show Error" then begin
            JSObject.ReadFrom(responseText);
            // errMessage := GetJSToken(JSObject, 'Message').AsValue().AsText();
            errExceptionMessage := GetJSToken(JSObject, 'ExceptionMessage').AsValue().AsText();
            // Error('Web service returned error:\\Status code: %1\\Description: %2\\Message: %3\\Exception Message: %4',
            //     ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase(), errMessage, errExceptionMessage);
            Error('Exception Message: %1', errExceptionMessage);
        end;

        exit(responseText);
    end;

    procedure InsertOperationToLog(Source: Code[10]; RestMethod: Code[10]; _URL: Text; _Autorization: Text; _Request: Text; _Response: Text; isSuccess: Boolean)
    var
        IntegrationLog: Record "Integration Log";
    begin
        IntegrationLog.Init();
        IntegrationLog."Operation Date" := CurrentDateTime;
        IntegrationLog."Source Operation" := Source;
        IntegrationLog.Autorization := CopyStr(_Autorization, 1, MaxStrLen(IntegrationLog.Autorization));
        IntegrationLog."Rest Method" := RestMethod;
        IntegrationLog.URL := _URL;
        IntegrationLog.Success := isSuccess;
        IntegrationLog.Insert(true);
        IntegrationLog.SetRequest(_Request);
        IntegrationLog.SetResponse(_Response);
        Commit();
    end;

    procedure GetOrdersFromShipStation(): Text
    var
        JSText: Text;
        JSObject: JsonObject;
        OrdersJSArray: JsonArray;
        OrderJSToken: JsonToken;
        Counter: Integer;
        txtOrders: Text;
        _SH: Record "Sales Header";
        txtMessage: TextConst ENU = 'Order(s) Updated:\ %1', RUS = 'Заказ(ы) обновлен(ы):\ %1';
    begin
        JSText := Connect2ShipStation(1, '', '');
        JSObject.ReadFrom(JSText);
        OrdersJSArray := GetJSToken(JSObject, 'orders').AsArray();

        for Counter := 0 to OrdersJSArray.Count - 1 do begin
            OrdersJSArray.Get(Counter, OrderJSToken);
            JSObject := OrderJSToken.AsObject();
            if _SH.Get(_SH."Document Type"::Order, GetJSToken(JSObject, 'orderNumber').AsValue().AsText()) then begin
                UpdateSalesHeaderFromShipStation(_SH."No.", JSObject);

                if txtOrders = '' then
                    txtOrders := GetJSToken(JSObject, 'orderNumber').AsValue().AsText()
                else
                    txtOrders += '|' + GetJSToken(JSObject, 'orderNumber').AsValue().AsText();
            end;

        end;
        Message(txtMessage, txtOrders);

        exit(txtOrders);
    end;

    procedure GetOrderFromShipStation(): Text
    var
        JSText: Text;
        JSObject: JsonObject;
        txtOrders: Text;
        _SH: Record "Sales Header";
    begin
        // Get Order from Shipstation to Fill Variables
        JSText := Connect2ShipStation(1, '', StrSubstNo('/%1', _SH."ShipStation Order ID"));

        JSObject.ReadFrom(JSText);

        txtOrders := GetJSToken(JSObject, 'orderNumber').AsValue().AsText();
        if _SH.Get(_SH."Document Type"::Order, GetJSToken(JSObject, 'orderNumber').AsValue().AsText()) then
            UpdateSalesHeaderFromShipStation(_SH."No.", JSObject);
    end;

    local procedure GetShippingAgentService(_ServiceCode: Text[100]; _CarrierCode: Text[50]): Code[10]
    var
        _SAS: Record "Shipping Agent Services";
    begin
        _SAS.SetCurrentKey("SS Code", "SS Carrier Code");
        _SAS.SetRange("SS Carrier Code", _CarrierCode);
        _SAS.SetRange("SS Code", _ServiceCode);
        if _SAS.FindFirst() then
            exit(_SAS.Code);

        GetServicesFromShipStation(_CarrierCode);
        _SAS.FindFirst();
        exit(_SAS.Code);
    end;

    local procedure GetShippingAgent(_CarrierCode: Text[50]): Code[10]
    var
        _SA: Record "Shipping Agent";
    begin
        _SA.SetCurrentKey("SS Code");
        _SA.SetRange("SS Code", _CarrierCode);
        if _SA.FindFirst() then
            exit(_SA.Code)
        else
            exit(GetCarrierFromShipStation(_CarrierCode));
    end;

    procedure CreateOrderInShipStation(DocNo: Code[20]): Boolean
    var
        _SH: Record "Sales Header";
        _Cust: Record Customer;
        JSText: Text;
        JSObjectHeader: JsonObject;
        jsonTagsArray: JsonArray;
    begin
        GetShipStationSetup();
        if not glShipStationSetup."ShipStation Integration Enable" then exit;

        if (DocNo = '') or (not _SH.Get(_SH."Document Type"::Order, DocNo)) then exit(false);

        _Cust.Get(_SH."Sell-to Customer No.");
        JSObjectHeader.Add('orderNumber', _SH."No.");
        if _SH."ShipStation Order Key" <> '' then
            JSObjectHeader.Add('orderKey', _SH."ShipStation Order Key");
        JSObjectHeader.Add('orderDate', Date2Text4JSON(_SH."Posting Date"));
        JSObjectHeader.Add('paymentDate', Date2Text4JSON(_SH."Prepayment Due Date"));
        JSObjectHeader.Add('shipByDate', Date2Text4JSON(_SH."Shipment Date"));
        JSObjectHeader.Add('orderStatus', lblAwaitingShipment);
        JSObjectHeader.Add('customerUsername', _Cust."E-Mail");
        JSObjectHeader.Add('customerEmail', _Cust."E-Mail");
        JSObjectHeader.Add('billTo', jsonBillToFromSH(_SH."No."));
        JSObjectHeader.Add('shipTo', jsonShipToFromSH(_SH."No."));
        JSObjectHeader.Add('items', jsonItemsFromSL(_SH."No."));

        // uncomment when dimensions will be solution
        // JSObjectHeader.Add('dimensions', jsonDimentionsFromAttributeValue(_SH."No."));

        // Carrier and Service are read only
        // JSObjectHeader.Add('carrierCode', GetCarrierCodeByAgentCode(_SH."Shipping Agent Code"));
        // JSObjectHeader.Add('serviceCode', GetServiceCodeByAgentServiceCode(_SH."Shipping Agent Code", _SH."Shipping Agent Service Code"));

        // Clear(jsonTagsArray);
        JSObjectHeader.Add('tagIds', jsonTagsArray);
        JSObjectHeader.WriteTo(JSText);

        JSText := Connect2ShipStation(2, JSText, '');

        // update Sales Header from ShipStation
        JSObjectHeader.ReadFrom(JSText);
        UpdateSalesHeaderFromShipStation(DocNo, JSObjectHeader);
    end;

    procedure CreateJsonItemForWooComerse(ItemNo: Code[20]): JsonObject
    var
        _Item: Record Item;
        _ItemDescription: Record "Item Description";
        _jsonText: Text;
        _jsonObject: JsonObject;
        _SalesPrice: Decimal;
    begin
        if (ItemNo = '') or not _Item.Get(ItemNo) or not _ItemDescription.Get(ItemNo) then exit(_jsonObject);

        _jsonObject.Add('itemId', _Item.SystemId);
        _jsonObject.Add('SKU', _Item."No.");
        _jsonObject.Add('name', jsonGetName(_Item."No."));
        _jsonObject.Add('price_regular', _Item."Unit Price");
        _SalesPrice := Round(_GetItemPrice(_Item."No."), 0.01, '>');
        if _SalesPrice < _Item."Unit Price" then begin
            _jsonObject.Add('price_sale', _SalesPrice);
            _jsonObject.Add('discount_value', _SalesPrice * 100 / _Item."Unit Price");
        end else begin
            _jsonObject.Add('price_sale', 0);
            _jsonObject.Add('discount_value', 0);
        end;
        _jsonObject.Add('available', jsonGetInventory(_Item."No."));
        _jsonObject.Add('category', jsonGetCategory(_Item."Item Category Code", 0));
        _jsonObject.Add('subcategory', jsonGetCategory(_Item."Item Category Code", 1));
        _jsonObject.Add('subsubcategory', jsonGetCategory(_Item."Item Category Code", 2));
        _jsonObject.Add('filters_group', jsonGetFilterGroupArray(_Item."No."));
        _jsonObject.Add('release_form', _Item."Item Form");
        _jsonObject.Add('weight', jsonWeightFromItem(_Item."Gross Weight"));
        _jsonObject.Add('brand', jsonGetBrand(_Item."Brand Code", _Item."Manufacturer Code"));
        _jsonObject.Add('manufacturer', jsonGetManufacturer(_Item."Manufacturer Code"));
        _jsonObject.Add('description', jsonGetBlobFromItemDescription(_Item."No.", _ItemDescription.FieldNo(Description), _ItemDescription.FieldNo("Description RU")));
        _jsonObject.Add('indication', jsonGetBlobFromItemDescription(_Item."No.", _ItemDescription.FieldNo(Indications), _ItemDescription.FieldNo("Indications RU")));
        _jsonObject.Add('ingredients', jsonGetBlobFromItemDescription(_Item."No.", _ItemDescription.FieldNo(Ingredients), _ItemDescription.FieldNo("Ingredients RU")));
        _jsonObject.Add('warning', jsonGetBlobFromItemDescription(_Item."No.", _ItemDescription.FieldNo(Warning), 0));
        _jsonObject.Add('legal_disclaimer', jsonGetBlobFromItemDescription(_Item."No.", _ItemDescription.FieldNo("Legal Disclaimer"), 0));
        _jsonObject.Add('directions', jsonGetBlobFromItemDescription(_Item."No.", _ItemDescription.FieldNo(Directions), _ItemDescription.FieldNo("Directions RU")));
        _jsonObject.Add('bullet_points', jsonGetBulletPoints(_Item."No."));
        _jsonObject.Add('images', jsonGetImages(_Item."No."));
        _jsonObject.Add('delivery', false); // TO DO
        if _ItemDescription."Sell-out" = 0D then
            _jsonObject.Add('is_sale', false)
        else
            _jsonObject.Add('is_sale', Today <= _ItemDescription."Sell-out");
        if _ItemDescription.New = 0D then
            _jsonObject.Add('is_new', false)
        else
            _jsonObject.Add('is_new', Today <= _ItemDescription.New);


        _jsonObject.WriteTo(_jsonText);
        exit(_jsonObject);
    end;

    local procedure jsonGetImages(_ItemNo: Code[20]): JsonArray
    var
        _ItemDescription: Record "Item Description";
        _jsonArray: JsonArray;
    begin
        if not _ItemDescription.Get(_ItemNo) then exit(_jsonArray);

        if _ItemDescription."Main Image URL" <> '' then
            _jsonArray.Add(_ItemDescription."Main Image URL");
        if _ItemDescription."Other Image URL" <> '' then
            _jsonArray.Add(_ItemDescription."Other Image URL");
        if _ItemDescription."Label Image URL" <> '' then
            _jsonArray.Add(_ItemDescription."Label Image URL");
        if _ItemDescription."Label Image URL 2" <> '' then
            _jsonArray.Add(_ItemDescription."Label Image URL 2");

        exit(_jsonArray);
    end;

    local procedure jsonGetBulletPoints(_ItemNo: Code[20]): JsonObject
    var
        _ItemDescription: Record "Item Description";
        _jsonObject: JsonObject;
        _jsonArray: JsonArray;
        _txtDescription: Text;
    begin
        if not _ItemDescription.Get(_ItemNo) then exit(_jsonObject);

        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 1"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 2"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 3"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 4"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _jsonArray.Add(_ItemDescription."Bullet Point 5");
        _jsonObject.Add('eng', _jsonArray);

        Clear(_jsonArray);
        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 1 RU"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 2 RU"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 3 RU"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _ItemDescription.BlobOnAfterGetRec(_ItemDescription.FieldNo("Bullet Point 4 RU"), _txtDescription);
        _jsonArray.Add(_txtDescription);
        _jsonArray.Add(_ItemDescription."Bullet Point 5 RU");
        _jsonObject.Add('ru', _jsonArray);

        exit(_jsonObject);
    end;

    local procedure jsonGetBlobFromItemDescription(_ItemNo: Code[20]; engFiledNo: Integer; ruFiledNo: Integer): JsonObject
    var
        _ItemDescription: Record "Item Description";
        _jsonObject: JsonObject;
        _txtDescription: Text;
    begin
        if not _ItemDescription.Get(_ItemNo) then exit(_jsonObject);

        if engFiledNo <> 0 then
            _ItemDescription.BlobOnAfterGetRec(engFiledNo, _txtDescription);
        _jsonObject.Add('eng', _txtDescription);

        Clear(_txtDescription);
        if ruFiledNo <> 0 then
            _ItemDescription.BlobOnAfterGetRec(ruFiledNo, _txtDescription);
        _jsonObject.Add('ru', _txtDescription);

        exit(_jsonObject)
    end;

    local procedure jsonGetManufacturer(_ManufacturerCode: Code[10]): JsonObject
    var
        _Manufacturer: Record Manufacturer;
        _jsonObject: JsonObject;
    begin
        if not _Manufacturer.Get(_ManufacturerCode) then exit(_jsonObject);

        _jsonObject.Add('id', _Manufacturer.Code);
        _jsonObject.Add('name', _Manufacturer.Name);
        _jsonObject.Add('name_ru', _Manufacturer."Name RU"); // added 11/09/2020

        exit(_jsonObject)
    end;

    local procedure jsonGetBrand(_BrandCode: Code[20]; _ManufacturerCode: Code[10]): JsonObject
    var
        _Brand: Record Brand;
        _jsonObject: JsonObject;
    begin
        if not _Brand.Get(_BrandCode, _ManufacturerCode) then exit(_jsonObject);

        _jsonObject.Add('id', _Brand.Code);
        _jsonObject.Add('name', _Brand.Name);
        _jsonObject.Add('name_ru', _Brand."Name RU"); // added 11/09/2020

        exit(_jsonObject)
    end;

    local procedure jsonGetFilterGroupArray(_ItemNo: Code[20]): JsonArray
    var
        _ItemFilterGroup: Record "Item Filter Group";
        _oldItemFilterGroup: Text[50];
        _jsonItemFilterGroupArray: JsonArray;
        _jsonItemFilterGroup: JsonObject;
        _jsonItemFilters: JsonArray;
    begin
        _ItemFilterGroup.SetRange("Item No.", _ItemNo);
        if _ItemFilterGroup.FindSet(false, false) then
            repeat
                if _oldItemFilterGroup <> _ItemFilterGroup."Filter Group" then begin
                    _jsonItemFilterGroup.Add('name', _ItemFilterGroup."Filter Group");
                    _jsonItemFilterGroup.Add('name_ru', _ItemFilterGroup."Filter Group RUS"); // added 11/09/2020 >>
                    _jsonItemFilterGroup.Add('filters', AddItemFilterGroupArray(_ItemFilterGroup."Item No.", _ItemFilterGroup."Filter Group"));
                    _jsonItemFilterGroup.Add('filters_ru', AddItemFilterGroupRUSArray(_ItemFilterGroup."Item No.", _ItemFilterGroup."Filter Group")); // added 11/09/2020 >>
                    _jsonItemFilterGroupArray.Add(_jsonItemFilterGroup);
                    _jsonItemFilters.Add(_jsonItemFilterGroup);
                    Clear(_jsonItemFilterGroup);
                    _oldItemFilterGroup := _ItemFilterGroup."Filter Group";
                end;
            until _ItemFilterGroup.Next() = 0;
        exit(_jsonItemFilters);
    end;

    local procedure AddItemFilterGroupArray(_ItemNo: Code[20]; _FilterGroup: Text[50]): JsonArray
    var
        _ItemFilterGroup: Record "Item Filter Group";
        _jsonItemFilterGroupArray: JsonArray;
    begin
        _ItemFilterGroup.SetRange("Item No.", _ItemNo);
        _ItemFilterGroup.SetRange("Filter Group", _FilterGroup);
        if _ItemFilterGroup.FindSet(false, false) then
            repeat
                _jsonItemFilterGroupArray.Add(_ItemFilterGroup."Filter Value");
            until _ItemFilterGroup.Next() = 0;
        exit(_jsonItemFilterGroupArray);
    end;

    local procedure AddItemFilterGroupRUSArray(_ItemNo: Code[20]; _FilterGroup: Text[50]): JsonArray
    var
        _ItemFilterGroup: Record "Item Filter Group";
        _jsonItemFilterGroupArray: JsonArray;
    begin
        _ItemFilterGroup.SetRange("Item No.", _ItemNo);
        _ItemFilterGroup.SetRange("Filter Group", _FilterGroup);
        if _ItemFilterGroup.FindSet(false, false) then
            repeat
                _jsonItemFilterGroupArray.Add(_ItemFilterGroup."Filter Value RUS");
            until _ItemFilterGroup.Next() = 0;
        exit(_jsonItemFilterGroupArray);
    end;

    local procedure AddItemFilterGroupRUArray(_ItemNo: Code[20]; _FilterGroup: Text[50]): JsonArray
    var
        _ItemFilterGroup: Record "Item Filter Group";
        _jsonItemFilterGroupArray: JsonArray;
    begin
        _ItemFilterGroup.SetRange("Item No.", _ItemNo);
        _ItemFilterGroup.SetRange("Filter Group", _FilterGroup);
        if _ItemFilterGroup.FindSet(false, false) then
            repeat
                _jsonItemFilterGroupArray.Add(_ItemFilterGroup."Filter Value RUS");
            until _ItemFilterGroup.Next() = 0;
        exit(_jsonItemFilterGroupArray);
    end;

    local procedure jsonGetCategory(_ItemCategoryCode: Code[20]; _Level: Integer): JsonObject
    var
        _ItemCategory: Record "Item Category";
        _jsonObject: JsonObject;
        _ParentCategory: Code[20];
    begin
        if not _ItemCategory.Get(_ItemCategoryCode) or (_ItemCategoryCode = '') then exit(_jsonObject);

        if _ItemCategory.Indentation = _Level then begin
            _jsonObject.Add('id', _ItemCategory.Description);
            _jsonObject.Add('eng', _ItemCategory.Description);
            exit(_jsonObject);
        end;
        if _ItemCategory."Parent Category" <> '' then
            exit(jsonGetCategory(_ItemCategory."Parent Category", _Level));
        exit(_jsonObject);
    end;

    local procedure jsonGetInventory(_ItemNo: Code[20]): Integer
    var
        _Item: Record Item;
    begin
        if not _Item.Get(_ItemNo) then exit(0);
        _Item.CalcFields(Inventory);
        case _Item.Inventory of
            0:
                exit(0);
            else
                if _Item.Inventory > _Item."Warning Qty" then
                    exit(1)
                else
                    exit(2);
        end;
    end;

    local procedure _GetItemPrice(_ItemNo: Code[20]): Decimal
    var
        _Item: Record Item;
    begin
        if not _Item.Get(_ItemNo) then exit(0);

        exit(_Item."Unit Price");
    end;

    local procedure jsonGetName(_ItemNo: Code[20]): JsonObject
    var
        _ItemDescr: Record "Item Description";
        _Item: Record Item;
        _jsonObject: JsonObject;
    begin
        if not _Item.Get(_ItemNo) or not _ItemDescr.Get(_ItemNo) then exit(_jsonObject);

        _jsonObject.Add('eng', _Item.Description + _Item."Description 2");
        _jsonObject.Add('ru', _ItemDescr."Name RU" + _ItemDescr."Name RU 2");

        exit(_jsonObject)
    end;

    local procedure GetCarrierCodeByAgentCode(ShippingAgentCode: Code[10]): Text[50]
    var
        _SA: Record "Shipping Agent";
        _jsonNull: JsonObject;
    begin
        if _SA.Get(ShippingAgentCode) then
            exit(_SA."SS Code")
        else
            exit('');
    end;

    local procedure GetServiceCodeByAgentServiceCode(ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]): Text[50]
    var
        _SAS: Record "Shipping Agent Services";
        _jsonNull: JsonObject;
    begin
        if _SAS.Get(ShippingAgentCode, ShippingAgentServiceCode) then
            exit(_SAS."SS Code")
        else
            exit('');
    end;

    procedure UpdateSalesHeaderFromShipStation(DocNo: Code[20]; _jsonObject: JsonObject): Boolean
    var
        _SH: Record "Sales Header";
        txtCarrierCode: Text[50];
        txtServiceCode: Text[100];
        _jsonToken: JsonToken;
    begin
        if not _SH.Get(_SH."Document Type"::Order, DocNo) then exit(false);
        // update Sales Header from ShipStation

        _jsonToken := GetJSToken(_jsonObject, 'carrierCode');
        if not _jsonToken.AsValue().IsNull then begin
            txtCarrierCode := CopyStr(GetJSToken(_jsonObject, 'carrierCode').AsValue().AsText(), 1, MaxStrLen(txtCarrierCode));
            _SH."Shipping Agent Code" := GetShippingAgent(txtCarrierCode);
            _jsonToken := GetJSToken(_jsonObject, 'serviceCode');
            if not _jsonToken.AsValue().IsNull then begin
                txtServiceCode := CopyStr(GetJSToken(_jsonObject, 'serviceCode').AsValue().AsText(), 1, MaxStrLen(txtServiceCode));
                _SH."Shipping Agent Service Code" := GetShippingAgentService(txtServiceCode, txtCarrierCode);
            end;
            // Get Rate

        end;
        _SH."ShipStation Order ID" := GetJSToken(_jsonObject, 'orderId').AsValue().AsText();
        _SH."ShipStation Order Key" := GetJSToken(_jsonObject, 'orderKey').AsValue().AsText();
        _SH."ShipStation Status" := CopyStr(GetJSToken(_jsonObject, 'orderStatus').AsValue().AsText(), 1, MaxStrLen(_SH."ShipStation Status"));
        _SH."ShipStation Shipment Amount" := GetJSToken(_jsonObject, 'shippingAmount').AsValue().AsDecimal();

        // case _SH."ShipStation Order Status" of
        //     _SH."ShipStation Order Status"::"Not Sent":
        //         _SH."ShipStation Order Status" := _SH."ShipStation Order Status"::Sent;
        //     _SH."ShipStation Order Status"::Sent:
        //         _SH."ShipStation Order Status" := _SH."ShipStation Order Status"::Updated;
        // end;

        if _SH."ShipStation Status" = lblAwaitingShipment then begin
            _SH."Package Tracking No." := '';
            _SH."ShipStation Shipment ID" := '';
        end;
        _SH.Modify();
    end;

    procedure CreateLabel2OrderInShipStation(DocNo: Code[20]): Boolean
    var
        _SH: Record "Sales Header";
        JSText: Text;
        JSObject: JsonObject;
        jsLabelObject: JsonObject;
        OrdersJSArray: JsonArray;
        OrderJSToken: JsonToken;
        Counter: Integer;
        notExistOrdersList: Text;
        OrdersListCreateLabel: Text;
        OrdersCancelled: Text;
        txtLabel: Text;
        txtBeforeName: Text;
        WhseShipDocNo: Code[20];
        errorShipStationOrderNotExist: TextConst ENU = 'ShipStation Order is not Existed!';
    begin
        GetShipStationSetup();
        if not glShipStationSetup."ShipStation Integration Enable" then exit;

        if (DocNo = '') or (not _SH.Get(_SH."Document Type"::Order, DocNo)) or (_SH."ShipStation Order ID" = '') then Error(errorShipStationOrderNotExist);
        // comment to test Create Label and Attache to Warehouse Shipment
        if not FindWarehouseSipment(DocNo, WhseShipDocNo) then Error(errorWhseShipNotExist, DocNo);

        // Get Order from Shipstation to Fill Variables
        JSText := Connect2ShipStation(1, '', StrSubstNo('/%1', _SH."ShipStation Order ID"));
        JSObject.ReadFrom(JSText);

        UpdateSalesHeaderFromShipStation(_SH."No.", JSObject);
        JSText := Connect2ShipStation(3, FillValuesFromOrder(JSObject, DocNo, GetLocationCode(DocNo)), '');

        // Update Order From Label
        UpdateOrderFromLabel(_SH."No.", JSText);

        // Add Lable to Shipment
        jsLabelObject.ReadFrom(JSText);
        txtLabel := GetJSToken(jsLabelObject, 'labelData').AsValue().AsText();
        txtBeforeName := _SH."No." + '-' + GetJSToken(jsLabelObject, 'trackingNumber').AsValue().AsText();
        SaveLabel2Shipment(txtBeforeName, txtLabel, WhseShipDocNo);

        ChangeShipStationStatusInSOToShipped(_SH."No.");
    end;

    local procedure ChangeShipStationStatusInSOToShipped(salesOrderNo: Code[20]);
    var
        salesHeader: Record "Sales Header";
    begin
        salesHeader.Get(salesHeader."Document Type"::Order, salesOrderNo);
        salesHeader."ShipStation Status" := lblShipped;
        salesHeader.Modify();
    end;

    local procedure GetLocationCode(DocNo: Code[20]): Code[10]
    var
        _SalesLine: Record "Sales Line";
    begin
        _SalesLine.SetRange("Document No.", DocNo);
        _SalesLine.SetRange("Document Type", _SalesLine."Document Type"::Order);
        if _SalesLine.FindFirst() then exit(_SalesLine."Location Code");
        exit('');
    end;

    procedure VoidLabel2OrderInShipStation(DocNo: Code[20]): Boolean
    var
        _SH: Record "Sales Header";
        JSText: Text;
        JSObject: JsonObject;
        WhseShipDocNo: Code[20];
        lblOrder: TextConst ENU = 'LabelOrder';
        FileName: Text;
        _txtBefore: Text;
    begin
        GetShipStationSetup();
        if not glShipStationSetup."ShipStation Integration Enable" then exit;

        if (DocNo = '') or (not _SH.Get(_SH."Document Type"::Order, DocNo)) or (_SH."ShipStation Shipment ID" = '') then exit(false);

        if not FindWarehouseSipment(DocNo, WhseShipDocNo) then Error(errorWhseShipNotExist, DocNo);

        // Void Label in Shipstation
        JSObject.Add('shipmentId', _SH."ShipStation Shipment ID");
        JSObject.WriteTo(JSText);
        JSText := Connect2ShipStation(8, JSText, '');
        // JSObject.ReadFrom(JSText);

        _txtBefore := _SH."No." + '-' + _SH."Package Tracking No.";
        FileName := StrSubstNo('%1-%2', _txtBefore, lblOrder);
        DeleteAttachment(WhseShipDocNo, FileName);

        CleareTrackingNoShipmentIDInSO(_SH."No.");
    end;

    procedure CleareTrackingNoShipmentIDInSO(salesOrderNo: Code[20]);
    var
        salesHeader: Record "Sales Header";
    begin
        salesHeader.Get(salesHeader."Document Type"::Order, salesOrderNo);
        salesHeader."Package Tracking No." := '';
        salesHeader."ShipStation Shipment ID" := '';
        salesHeader."ShipStation Status" := lblAwaitingShipment;
        salesHeader.Modify();
    end;

    local procedure UpdateOrderFromLabel(DocNo: Code[20]; jsonText: Text);
    var
        _SH: Record "Sales Header";
        jsLabelObject: JsonObject;
    begin
        _SH.Get(_SH."Document Type"::Order, DocNo);
        jsLabelObject.ReadFrom(jsonText);
        _SH."ShipStation Insurance Cost" := GetJSToken(jsLabelObject, 'insuranceCost').AsValue().AsDecimal();
        _SH."ShipStation Shipment Cost" := GetJSToken(jsLabelObject, 'shipmentCost').AsValue().AsDecimal();
        _SH."Package Tracking No." := GetJSToken(jsLabelObject, 'trackingNumber').AsValue().AsText();
        _SH."ShipStation Shipment ID" := GetJSToken(jsLabelObject, 'shipmentId').AsValue().AsText();
        _SH.Modify();
    end;

    procedure FindWarehouseSipment(_DocNo: Code[20]; var _WhseShipDcoNo: Code[20]): Boolean
    var
        WhseShipLine: Record "Warehouse Shipment Line";
    begin
        WhseShipLine.SetCurrentKey("Source Document", "Source No.");
        WhseShipLine.SetRange("Source Document", WhseShipLine."Source Document"::"Sales Order");
        WhseShipLine.SetRange("Source No.", _DocNo);
        if WhseShipLine.FindFirst() then begin
            _WhseShipDcoNo := WhseShipLine."No.";
            exit(true);
        end;
        exit(false);
    end;

    procedure SaveLabel2Shipment(_txtBefore: Text; _txtLabelBase64: Text; _WhseShipDocNo: Code[20])
    var
        RecRef: RecordRef;
        WhseShipHeader: Record "Warehouse Shipment Header";
        lblOrder: TextConst ENU = 'LabelOrder';
        FileName: Text;
        tempblob: Codeunit "Temp Blob";
    begin
        RecRef.OPEN(DATABASE::"Warehouse Shipment Header");
        WhseShipHeader.Get(_WhseShipDocNo);
        RecRef.GETTABLE(WhseShipHeader);
        FileName := StrSubstNo('%1-%2.pdf', _txtBefore, lblOrder);
        SaveAttachment2WhseShmt(RecRef, FileName, _txtLabelBase64);
    end;

    local procedure SaveAttachment2WhseShmt(RecRef: RecordRef; IncomingFileName: Text; LabelBase64: Text)
    var
        FieldRef: FieldRef;
        _InStream: InStream;
        _OutStream: OutStream;
        RecNo: Code[20];
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        LineNo: Integer;
        TenantMedia: Record "Tenant Media";
        DocumentAttachment: Record "Document Attachment";
        FileManagement: Codeunit "File Management";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        DocumentAttachment.Init();
        DocumentAttachment.Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
        DocumentAttachment.Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen(DocumentAttachment."File Name")));

        TenantMedia.Content.CreateOutStream(_OutStream);
        Base64Convert.FromBase64(LabelBase64, _OutStream);
        TenantMedia.Content.CreateInStream(_InStream);
        DocumentAttachment."Document Reference ID".ImportStream(_InStream, IncomingFileName);

        DocumentAttachment.Validate("Table ID", RecRef.Number);
        FieldRef := RecRef.Field(1);
        RecNo := FieldRef.Value;
        DocumentAttachment.Validate("No.", RecNo);
        DocumentAttachment.Insert(true);
    end;

    procedure DeleteAttachment(_WhseShipDocNo: Code[20]; _FileName: Text[250])
    var
        DocumentAttachment: Record "Document Attachment";
        WhseShipHeader: Record "Warehouse Shipment Header";
        _RecordRef: RecordRef;
        _FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        _RecordRef.OPEN(DATABASE::"Warehouse Shipment Header");
        WhseShipHeader.Get(_WhseShipDocNo);
        _RecordRef.GETTABLE(WhseShipHeader);

        _FieldRef := _RecordRef.Field(1);
        RecNo := _FieldRef.Value;

        DocumentAttachment.SetCurrentKey("Table ID", "No.", "File Name");
        DocumentAttachment.SetRange("Table ID", _RecordRef.Number);
        DocumentAttachment.SetRange("No.", RecNo);
        DocumentAttachment.SetRange("File Name", _FileName);
        DocumentAttachment.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Page, 1174, 'OnBeforeDrillDown', '', true, true)]
    local procedure BeforeDrillDownSetFilters(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        WSHeader: Record "Warehouse Shipment Header";
    begin
        RecRef.OPEN(DATABASE::"Warehouse Shipment Header");
        IF WSHeader.GET(DocumentAttachment."No.") THEN
            RecRef.GETTABLE(WSHeader);
    end;

    [EventSubscriber(ObjectType::Page, 1173, 'OnAfterOpenForRecRef', '', true, true)]
    local procedure AfterOpenForRecRefSetFilters(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Warehouse Shipment Header":
                BEGIN
                    DocumentAttachment.SetRange("Table ID", Database::"Warehouse Shipment Header");
                    FieldRef := RecRef.FIELD(1);
                    RecNo := FieldRef.VALUE;
                    DocumentAttachment.SETRANGE("No.", RecNo);
                END;
        END;
    end;

    local procedure CreateListAsFilter(var _List: Text; _subString: Text)
    begin
        if _List = '' then
            _List += _subString
        else
            _List += '|' + _subString;
    end;

    procedure FillValuesFromOrder(_JSObject: JsonObject; DocNo: Code[20]; LocationCode: Code[20]): Text
    var
        JSObjectHeader: JsonObject;
        JSText: Text;
        jsonNull: JsonObject;
        jsonInsurance: JsonObject;
        jsonInternational: JsonObject;
        jsonInsuranceOptions: JsonObject;
    begin

        if GetJSToken(_JSObject, 'carrierCode').AsValue().IsNull then
            exit(StrSubstNo(errCarrierIsNull, GetJSToken(_JSObject, 'orderNumber').AsValue().AsText()));
        if GetJSToken(_JSObject, 'serviceCode').AsValue().IsNull then
            exit(StrSubstNo(errServiceIsNull, GetJSToken(_JSObject, 'orderNumber').AsValue().AsText()));

        JSObjectHeader.Add('orderId', GetJSToken(_JSObject, 'orderId').AsValue().AsInteger());
        JSObjectHeader.Add('carrierCode', GetJSToken(_JSObject, 'carrierCode').AsValue().AsText());
        JSObjectHeader.Add('serviceCode', GetJSToken(_JSObject, 'serviceCode').AsValue().AsText());
        JSObjectHeader.Add('packageCode', GetJSToken(_JSObject, 'packageCode').AsValue().AsText());
        JSObjectHeader.Add('confirmation', GetJSToken(_JSObject, 'confirmation').AsValue().AsText());
        JSObjectHeader.Add('shipDate', Date2Text4SS(Today));
        JSObjectHeader.Add('weight', GetJSToken(_JSObject, 'weight').AsObject());

        jsonInsurance := GetJSToken(_JSObject, 'insuranceOptions').AsObject();
        if not GetJSToken(jsonInsurance, 'insureShipment').AsValue().AsBoolean() then begin
            jsonInsuranceOptions.Add('provider', 'carrier');
            jsonInsuranceOptions.Add('insureShipment', true);
            jsonInsuranceOptions.Add('insuredValue', GetJSToken(_JSObject, 'orderTotal').AsValue().AsDecimal());
        end else
            jsonInsuranceOptions := jsonInsurance;
        JSObjectHeader.Add('insuranceOptions', jsonInsuranceOptions);

        JSObjectHeader.Add('testLabel', false);
        JSObjectHeader.WriteTo(JSText);
        exit(JSText);
    end;

    procedure jsonBillToFromSH(DocNo: Code[20]): JsonObject
    var
        JSObjectLine: JsonObject;
        _SH: Record "Sales Header";
        _Cust: Record Customer;
        _Contact: Record Contact;
    begin
        _SH.Get(_SH."Document Type"::Order, DocNo);
        _Cust.Get(_SH."Bill-to Customer No.");
        _Contact.Get(_SH."Bill-to Contact No.");

        JSObjectLine.Add('name', _SH."Bill-to Contact");
        JSObjectLine.Add('company', _Cust.Name);
        JSObjectLine.Add('street1', _SH."Bill-to Address");
        JSObjectLine.Add('street2', _SH."Bill-to Address 2");
        JSObjectLine.Add('street3', '');
        JSObjectLine.Add('city', _SH."Bill-to City");
        JSObjectLine.Add('state', _SH."Bill-to County");
        JSObjectLine.Add('postalCode', _SH."Bill-to Post Code");
        JSObjectLine.Add('country', _SH."Bill-to Country/Region Code");
        JSObjectLine.Add('phone', _Contact."Phone No.");
        JSObjectLine.Add('residential', false);
        exit(JSObjectLine);
    end;

    procedure jsonShipToFromSH(DocNo: Code[20]): JsonObject
    var
        JSObjectLine: JsonObject;
        _SH: Record "Sales Header";
    begin
        _SH.Get(_SH."Document Type"::Order, DocNo);

        JSObjectLine.Add('name', _SH."Ship-to Contact");
        JSObjectLine.Add('company', _SH."Sell-to Customer Name");
        JSObjectLine.Add('street1', _SH."Ship-to Address");
        JSObjectLine.Add('street2', _SH."Ship-to Address 2");
        JSObjectLine.Add('city', _SH."Ship-to City");
        JSObjectLine.Add('state', _SH."Ship-to County");
        JSObjectLine.Add('postalCode', _SH."Ship-to Post Code");
        JSObjectLine.Add('country', _SH."Ship-to Country/Region Code");
        JSObjectLine.Add('phone', _SH."Sell-to Phone No.");
        JSObjectLine.Add('residential', false);
        exit(JSObjectLine);
    end;

    local procedure jsonShipFrom(LocationCode: Code[10]): JsonObject
    var
        _jsonObject: JsonObject;
    begin
        _jsonObject := jsonShipFromFromLocation(LocationCode);
        if _jsonObject.Contains('name') then
            exit(_jsonObject)
        else
            exit(jsonShipFromFromCompaniInfo());
    end;

    procedure jsonShipFromFromLocation(LocationCode: Code[10]): JsonObject
    var
        JSObjectLine: JsonObject;
        _Location: Record Location;
    begin
        _Location.Get(LocationCode);
        if _Location.Address = '' then exit(JSObjectLine);
        JSObjectLine.Add('name', _Location.Contact);
        JSObjectLine.Add('company', _Location.Name + _Location."Name 2");
        JSObjectLine.Add('street1', _Location.Address);
        JSObjectLine.Add('street2', _Location."Address 2");
        JSObjectLine.Add('city', _Location.City);
        JSObjectLine.Add('state', _Location.County);
        JSObjectLine.Add('postalCode', _Location."Post Code");
        JSObjectLine.Add('country', _Location."Country/Region Code");
        JSObjectLine.Add('phone', _Location."Phone No.");
        JSObjectLine.Add('residential', false);
        exit(JSObjectLine);
    end;

    procedure jsonShipFromFromCompaniInfo(): JsonObject
    var
        JSObjectLine: JsonObject;
        _CompanyInfo: Record "Company Information";
    begin
        _CompanyInfo.Get();
        JSObjectLine.Add('name', _CompanyInfo."Ship-to Contact");
        JSObjectLine.Add('company', _CompanyInfo."Ship-to Name" + _CompanyInfo."Ship-to Name 2");
        JSObjectLine.Add('street1', _CompanyInfo."Ship-to Address");
        JSObjectLine.Add('street2', _CompanyInfo."Ship-to Address 2");
        JSObjectLine.Add('city', _CompanyInfo."Ship-to City");
        JSObjectLine.Add('state', _CompanyInfo."Ship-to County");
        JSObjectLine.Add('postalCode', _CompanyInfo."Ship-to Post Code");
        JSObjectLine.Add('country', _CompanyInfo."Ship-to Country/Region Code");
        JSObjectLine.Add('phone', _CompanyInfo."Phone No.");
        JSObjectLine.Add('residential', false);
        exit(JSObjectLine);
    end;

    procedure jsonItemsFromSL(DocNo: Code[20]): JsonArray
    var
        JSObjectLine: JsonObject;
        JSObjectArray: JsonArray;
        _SL: Record "Sales Line";
        _ID: Record "Item Description";
    begin
        _SL.SetCurrentKey(Type, Quantity);
        _SL.SetRange("Document Type", _SL."Document Type"::Order);
        _SL.SetRange("Document No.", DocNo);
        _SL.SetRange(Type, _SL.Type::Item);
        _SL.SetFilter(Quantity, '<>%1', 0);
        if _SL.FindSet(false, false) then
            repeat
                Clear(JSObjectLine);

                JSObjectLine.Add('lineItemKey', _SL."Line No.");
                JSObjectLine.Add('sku', _SL."No.");
                JSObjectLine.Add('name', _SL.Description);
                if _ID.Get(_SL."No.") then
                    JSObjectLine.Add('imageUrl', _ID."Main Image URL");
                JSObjectLine.Add('weight', jsonWeightFromItem(_SL."Gross Weight"));
                // JSObjectLine.Add('quantity', _SL.Quantity);
                JSObjectLine.Add('quantity', Decimal2Integer(_SL.Quantity));
                JSObjectLine.Add('unitPrice', Round(_SL."Amount Including VAT" / _SL.Quantity, 0.01));
                JSObjectLine.Add('taxAmount', Round((_SL."Amount Including VAT" - _SL.Amount) / _SL.Quantity, 0.01));
                // JSObjectLine.Add('shippingAmount', 0);
                JSObjectLine.Add('warehouseLocation', _SL."Location Code");
                JSObjectLine.Add('productId', _SL."Line No.");
                JSObjectLine.Add('fulfillmentSku', '');
                JSObjectLine.Add('adjustment', false);
                JSObjectArray.Add(JSObjectLine);
            until _SL.Next() = 0;
        exit(JSObjectArray);
    end;

    procedure Decimal2Integer(_Decimal: Decimal): Integer
    begin
        exit(Round(_Decimal, 1));
    end;

    procedure jsonWeightFromItem(_GrossWeight: Decimal): JsonObject
    var
        JSObjectLine: JsonObject;
    begin
        JSObjectLine.Add('value', _GrossWeight);
        JSObjectLine.Add('units', 'ounces'); // Lena confirmed
        exit(JSObjectLine);
    end;

    procedure jsonDimentionsFromAttributeValue(_No: Code[20]): JsonObject
    var
        JSObjectLine: JsonObject;
        lblInc: Label 'inches';
        lblCm: Label 'centimeters';
        txtUnits: Text;
        decDimension: Decimal;
    begin
        if Evaluate(decDimension, GetItemAttributeValue(Database::"Sales Header", _No, 'length', txtUnits)) then
            JSObjectLine.Add('length', decDimension);
        if Evaluate(decDimension, GetItemAttributeValue(Database::"Sales Header", _No, 'width', txtUnits)) then
            JSObjectLine.Add('width', decDimension);
        if Evaluate(decDimension, GetItemAttributeValue(Database::"Sales Header", _No, 'height', txtUnits)) then
            JSObjectLine.Add('height', decDimension);

        if txtUnits in [lblCm, lblInc] then
            JSObjectLine.Add('units', txtUnits)
        else
            JSObjectLine.Add('units', lblCm);
        exit(JSObjectLine);
    end;

    local procedure GetItemAttributeValue(TableID: Integer; ItemNo: Code[20]; TokenKey: Text; var _Units: Text): Text
    var
        _ItemAttr: Record "Item Attribute";
        _ItemAttrValue: Record "Item Attribute Value";
        _ItemAttrValueMapping: Record "Item Attribute Value Mapping";
        _UoM: Record "Unit of Measure";
    begin
        _ItemAttr.SetCurrentKey(Name);
        _ItemAttr.SetRange(Name, TokenKey);
        if _ItemAttr.FindFirst() then begin
            _Units := LowerCase(_ItemAttr."Unit of Measure");
            if _ItemAttrValueMapping.Get(TableID, ItemNo, _ItemAttr.ID) then begin
                _ItemAttrValue.Get(_ItemAttrValueMapping."Item Attribute ID", _ItemAttrValueMapping."Item Attribute Value ID");
                exit(_ItemAttrValue.Value);
            end;
        end;
        exit('');
    end;

    procedure GetJSToken(_JSONObject: JsonObject; TokenKey: Text) _JSONToken: JsonToken
    begin
        if not _JSONObject.Get(TokenKey, _JSONToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    procedure SelectJSToken(_JSONObject: JsonObject; Path: Text) _JSONToken: JsonToken
    begin
        if not _JSONObject.SelectToken(Path, _JSONToken) then
            Error('Could not find a token with path %1', Path);
    end;

    local procedure Date2Text4SS(_Date: Date): Text
    var
        _Year: Text[4];
        _Month: Text[2];
        _Day: Text[2];
    begin
        EVALUATE(_Day, Format(Date2DMY(_Date, 1)));
        AddZero2String(_Day, 2);
        EVALUATE(_Month, Format(Date2DMY(_Date, 2)));
        AddZero2String(_Month, 2);
        EVALUATE(_Year, Format(Date2DMY(_Date, 3)));
        EXIT(_Year + '-' + _Month + '-' + _Day);
    end;

    local procedure GetDateFromJsonText(_DateText: Text): Date
    var
        Year: Integer;
        Month: Integer;
        Day: Integer;
    begin
        EVALUATE(Year, COPYSTR(_DateText, 1, 4));
        EVALUATE(Month, COPYSTR(_DateText, 6, 2));
        EVALUATE(Day, COPYSTR(_DateText, 9, 2));
        EXIT(DMY2DATE(Day, Month, Year));
    end;

    procedure Date2Text4JSON(_Date: Date): Text
    var
        _Year: Text[4];
        _Month: Text[2];
        _Day: Text[2];
    begin
        EVALUATE(_Day, Format(Date2DMY(_Date, 1)));
        AddZero2String(_Day, 2);
        EVALUATE(_Month, Format(Date2DMY(_Date, 2)));
        AddZero2String(_Month, 2);
        EVALUATE(_Year, Format(Date2DMY(_Date, 3)));
        EXIT(_Year + '-' + _Month + '-' + _Day + 'T00:00:00.0000000');
    end;

    local procedure AddZero2String(var _String: Text; _maxLenght: Integer)
    begin
        while _maxLenght > StrLen(_String) do
            _String := StrSubstNo('%1%2', '0', _String);
    end;

    procedure GetCarrierFromShipStation(_SSAgentCode: Text[20]): Code[10]
    var
        JSText: Text;
        JSObject: JsonObject;
        CarrierToken: JsonToken;
        Counter: Integer;
        txtCarrierCode: Text[20];
        ShippingAgent: Record "Shipping Agent";
    begin
        JSText := Connect2ShipStation(6, '', _SSAgentCode);
        JSObject.ReadFrom(JSText);
        txtCarrierCode := CopyStr(GetJSToken(JSObject, 'code').AsValue().AsText(), 1, MaxStrLen(ShippingAgent."SS Code"));
        ShippingAgent.SetCurrentKey("SS Code");
        ShippingAgent.SetRange("SS Code", txtCarrierCode);
        if not ShippingAgent.FindFirst() then
            ShippingAgent.InsertCarrierFromShipStation(GetLastCarrierCode(), CopyStr(GetJSToken(JSObject, 'name').AsValue().AsText(), 1, MaxStrLen(ShippingAgent.Name)),
                                                       txtCarrierCode, GetJSToken(JSObject, 'shippingProviderId').AsValue().AsInteger());
        ShippingAgent.FindFirst();
        exit(ShippingAgent.Code);
    end;

    procedure GetCarriersFromShipStation(): Boolean
    var
        _SA: Record "Shipping Agent";
        JSText: Text;
        JSObject: JsonObject;
        CarriersJSArray: JsonArray;
        CarrierToken: JsonToken;
        Counter: Integer;
        txtCarrierCode: Text[20];
    begin
        JSText := Connect2ShipStation(4, '', '');

        CarriersJSArray.ReadFrom(JSText);
        foreach CarrierToken in CarriersJSArray do begin
            txtCarrierCode := CopyStr(GetJSToken(CarrierToken.AsObject(), 'code').AsValue().AsText(), 1, MaxStrLen(_SA."SS Code"));
            _SA.SetCurrentKey("SS Code");
            _SA.SetRange("SS Code", txtCarrierCode);
            if not _SA.FindFirst() then
                _SA.InsertCarrierFromShipStation(GetLastCarrierCode(), CopyStr(GetJSToken(CarrierToken.AsObject(), 'name').AsValue().AsText(), 1, MaxStrLen(_SA.Name)),
                                                           txtCarrierCode, GetJSToken(CarrierToken.AsObject(), 'shippingProviderId').AsValue().AsInteger());
        end;
        exit(true);
    end;

    procedure GetCarriersFromShipStationToUpdate()
    var
        _SA: Record "Shipping Agent";
        JSText: Text;
        JSObject: JsonObject;
        CarriersJSArray: JsonArray;
        CarrierToken: JsonToken;
        Counter: Integer;
        txtCarrierCode: Text[20];
    begin
        JSText := Connect2ShipStation(4, '', '');

        CarriersJSArray.ReadFrom(JSText);
        _SA.SetCurrentKey("SS Code");
        foreach CarrierToken in CarriersJSArray do begin
            txtCarrierCode := CopyStr(GetJSToken(CarrierToken.AsObject(), 'code').AsValue().AsText(), 1, MaxStrLen(_SA."SS Code"));
            _SA.SetRange("SS Code", txtCarrierCode);
            if not _SA.FindFirst() then
                _SA.InsertCarrierFromShipStation(GetLastCarrierCode(), CopyStr(GetJSToken(CarrierToken.AsObject(), 'name').AsValue().AsText(), 1, MaxStrLen(_SA.Name)),
                                                           txtCarrierCode, GetJSToken(CarrierToken.AsObject(), 'shippingProviderId').AsValue().AsInteger());
            GetServicesFromShipStationToUpdate(txtCarrierCode);
        end;
    end;

    procedure GetServicesFromShipStationToUpdate(_SSAgentCode: Text[20])
    var
        JSText: Text;
        JSObject: JsonObject;
        CarriersJSArray: JsonArray;
        CarrierToken: JsonToken;
        Counter: Integer;
        ShippingAgentServices: Record "Shipping Agent Services";
        _SSCode: Text[50];
    begin
        JSText := Connect2ShipStation(5, '', _SSAgentCode);

        CarriersJSArray.ReadFrom(JSText);
        ShippingAgentServices.SetCurrentKey("SS Carrier Code", "SS Code");
        foreach CarrierToken in CarriersJSArray do begin
            _SSAgentCode := CopyStr(GetJSToken(CarrierToken.AsObject(), 'carrierCode').AsValue().AsText(), 1, MaxStrLen(ShippingAgentServices."SS Carrier Code"));
            _SSCode := CopyStr(GetJSToken(CarrierToken.AsObject(), 'code').AsValue().AsText(), 1, MaxStrLen(ShippingAgentServices."SS Code"));

            ShippingAgentServices.SetRange("SS Carrier Code", _SSAgentCode);
            ShippingAgentServices.SetRange("SS Code", _SSCode);
            if not ShippingAgentServices.FindFirst() then
                ShippingAgentServices.InsertServicesFromShipStation(GetCarrierCodeBySSAgentCode(_SSAgentCode), GetLastCarrierServiceCode(GetCarrierCodeBySSAgentCode(_SSAgentCode)), _SSAgentCode, _SSCode,
                                              CopyStr(GetJSToken(CarrierToken.AsObject(), 'name').AsValue().AsText(), 1, MaxStrLen(ShippingAgentServices.Description)));
        end;
    end;

    local procedure GetLastCarrierCode(): Code[10]
    var
        ShippingAgent: Record "Shipping Agent";
        lblSA_Code: Label 'SA-0001';
        lblSA_CodeFilter: Label 'SA-*';
    begin
        ShippingAgent.SetFilter(Code, '%1', lblSA_CodeFilter);
        if ShippingAgent.FindLast() then exit(IncStr(ShippingAgent.Code));
        exit(lblSA_Code);
    end;

    local procedure TempGetLastCarrierCode(var ShippingAgent: Record "Shipping Agent" temporary): Code[10]
    var
        lblSA_Code: Label 'SA-0001';
        lblSA_CodeFilter: Label 'SA-*';
    begin
        ShippingAgent.Reset();
        ShippingAgent.SetFilter(Code, '%1', lblSA_CodeFilter);
        if ShippingAgent.FindLast() then exit(IncStr(ShippingAgent.Code));
        exit(lblSA_Code);
    end;

    procedure GetServicesFromShipStation(_SSAgentCode: Text[20]): Boolean
    var
        JSText: Text;
        JSObject: JsonObject;
        CarriersJSArray: JsonArray;
        CarrierToken: JsonToken;
        Counter: Integer;
        ShippingAgentServices: Record "Shipping Agent Services";
        _SSCode: Text[50];
    begin
        JSText := Connect2ShipStation(5, '', _SSAgentCode);

        CarriersJSArray.ReadFrom(JSText);
        foreach CarrierToken in CarriersJSArray do begin
            _SSAgentCode := CopyStr(GetJSToken(CarrierToken.AsObject(), 'carrierCode').AsValue().AsText(), 1, MaxStrLen(ShippingAgentServices."SS Carrier Code"));
            _SSCode := CopyStr(GetJSToken(CarrierToken.AsObject(), 'code').AsValue().AsText(), 1, MaxStrLen(ShippingAgentServices."SS Code"));
            ShippingAgentServices.SetCurrentKey("SS Carrier Code", "SS Code");
            ShippingAgentServices.SetRange("SS Carrier Code", _SSAgentCode);
            ShippingAgentServices.SetRange("SS Code", _SSCode);
            if ShippingAgentServices.FindFirst() then exit(true);
            ShippingAgentServices.InsertServicesFromShipStation(GetCarrierCodeBySSAgentCode(_SSAgentCode), GetLastCarrierServiceCode(GetCarrierCodeBySSAgentCode(_SSAgentCode)), _SSAgentCode, _SSCode,
                                          CopyStr(GetJSToken(CarrierToken.AsObject(), 'name').AsValue().AsText(), 1, MaxStrLen(ShippingAgentServices.Description)));
        end;
        exit(true);
    end;

    local procedure GetCarrierCodeBySSAgentCode(_SSAgentCode: Text[20]): Code[10]
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.SetCurrentKey("SS Code");
        ShippingAgent.SetRange("SS Code", _SSAgentCode);
        ShippingAgent.FindFirst();
        exit(ShippingAgent.Code);
    end;

    local procedure GetLastCarrierServiceCode(AgentCode: Code[10]): Code[10]
    var
        locSAS: Record "Shipping Agent Services";
        lblSASCode: Label 'SAS-0001';
        lblSASCodeFilter: Label 'SAS-*';
    begin
        locSAS.SetRange("Shipping Agent Code", AgentCode);
        if locSAS.FindLast() then exit(IncStr(locSAS.Code));
        exit(lblSASCode);
    end;

    procedure GetShippingRatesByCarrier(_SH: Record "Sales Header")
    var
        TotalGrossWeight: Decimal;
    begin
        TotalGrossWeight := GetOrderGrossWeight(_SH);
        if not (TotalGrossWeight > 0) then Error(StrSubstNo(errTotalGrossWeightIsZero, TotalGrossWeight));
        // Update Carriers And Services
        // UpdateCarriersAndServices(_SA, _SAS);

        // UpdateCarriersAndServices();
        // Init Shipping Amount
        InitShippingAmount();
        // Get Rates By Carrier From ShipStation
        // GetRatesByCarrierFromShipStation(_SH, _SA, _SAS);
        GetRatesByCarrierFromShipStation(_SH);
    end;

    procedure GetOrderGrossWeight(SalesHeader: Record "Sales Header"): Decimal
    var
        _SL: Record "Sales Line";
        TotalGrossWeight: Decimal;
    begin
        TotalGrossWeight := 0;
        _SL.SetRange("Document Type", SalesHeader."Document Type");
        _SL.SetRange("Document No.", SalesHeader."No.");
        if _SL.FindSet(false, false) then
            repeat
                TotalGrossWeight += _SL.Quantity * _SL."Gross Weight";
            until _SL.Next() = 0;
        exit(TotalGrossWeight);
    end;

    procedure UpdateCarriersAndServices()
    var
        _SA: Record "Shipping Agent";
    begin
        // GetCarriersFromShipStation(_SA, _SAS);
        if Confirm(confUpdateCarriersList, false, _SA.TableCaption) then begin
            GetCarriersFromShipStationToUpdate();
            Message(msgCarriersListUpdated, _SA.TableCaption);
        end;
    end;

    procedure InitShippingAmount()
    var
        _SAS: Record "Shipping Agent Services";
    begin
        _SAS.ModifyAll("Shipment Cost", 0);
        _SAS.ModifyAll("Other Cost", 0);
    end;

    procedure GetRatesByCarrierFromShipStation(_SH: Record "Sales Header")
    var
        _SA: Record "Shipping Agent";
        jsText: Text;
        jsObject: JsonObject;
        jsRatesArray: JsonArray;
    begin
        _SA.SetCurrentKey("SS Code");
        _SA.SetFilter("SS Code", '<>%1', '');
        if _SA.FindSet() then
            repeat
                jsObject.Add('carrierCode', _SA."SS Code");
                jsObject.Add('fromPostalCode', GetFromPostalCode(_SH."Location Code"));
                jsObject.Add('toCountry', _SH."Sell-to Country/Region Code");
                jsObject.Add('toPostalCode', _SH."Sell-to Post Code");
                jsObject.Add('weight', jsonWeightFromItem(GetOrderGrossWeight(_SH)));
                jsObject.WriteTo(jsText);

                JSText := Connect2ShipStation(7, jsText, '');
                jsRatesArray.ReadFrom(jsText);

                // update Shipping Cost into Shipping Agent Service
                InsertServicesAndUpdateServiceCostsFromShipStation(_SA."SS Code", jsRatesArray);
                Clear(jsObject);
            until _SA.Next() = 0;
    end;

    procedure InsertServicesAndUpdateServiceCostsFromShipStation(CarrierCode: Text[20]; jsonRatesArray: JsonArray)
    var
        _SAS: Record "Shipping Agent Services";
        CarrierToken: JsonToken;
        ServiceCode: Text[100];
    begin
        foreach CarrierToken in jsonRatesArray do begin
            ServiceCode := CopyStr(GetJSToken(CarrierToken.AsObject(), 'serviceCode').AsValue().AsText(), 1, MaxStrLen(_SAS."SS Code"));
            _SAS.SetCurrentKey("SS Carrier Code", "SS Code");
            _SAS.SetRange("SS Carrier Code", CarrierCode);
            _SAS.SetRange("SS Code", ServiceCode);
            if not _SAS.FindFirst() then
                // Insert Services
                _SAS.InsertServicesFromShipStation(GetCarrierCodeBySSAgentCode(CarrierCode), GetLastCarrierServiceCode(GetCarrierCodeBySSAgentCode(CarrierCode)), CarrierCode, ServiceCode,
                                              CopyStr(GetJSToken(CarrierToken.AsObject(), 'serviceName').AsValue().AsText(), 1, MaxStrLen(_SAS.Description)));
            _SAS."Shipment Cost" := GetJSToken(CarrierToken.AsObject(), 'shipmentCost').AsValue().AsDecimal();
            _SAS."Other Cost" := GetJSToken(CarrierToken.AsObject(), 'otherCost').AsValue().AsDecimal();
            _SAS.Modify();
        end;
    end;

    procedure GetFromPostalCode(_LocationCode: Code[10]): Text
    var
        Location: Record Location;
        CompanyInfo: Record "Company Information";
    begin
        if Location.Get(_LocationCode) then exit(Location."Post Code");
        if CompanyInfo.Get() then exit(CompanyInfo."Ship-to Post Code");
    end;

    local procedure GetShipStationSetup()
    begin
        if not glShipStationSetup.Get() then begin
            glShipStationSetup.Init();
            glShipStationSetup.Insert();
        end;
    end;

    procedure GetCustomerNameFromWhseShipment(WhseShipmentNo: Code[20]): Text
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        SalesHeader: Record "Sales Header";
    begin
        WhseShipmentLine.SetRange("No.", WhseShipmentNo);
        if not WhseShipmentLine.FindFirst() then exit('');

        SalesHeader.Get(SalesHeader."Document Type"::Order, WhseShipmentLine."Source No.");
        exit(SalesHeader."Sell-to Customer Name");
    end;

    procedure GetCustomerNameFromWhsePick(WhsePickNo: Code[20]): Text
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        SalesHeader: Record "Sales Header";
    begin
        WhseActivityLine.SetRange("No.", WhsePickNo);
        if not WhseActivityLine.FindFirst() then exit('');

        SalesHeader.Get(SalesHeader."Document Type"::Order, WhseActivityLine."Source No.");
        exit(SalesHeader."Sell-to Customer Name");
    end;

    procedure CreateDeliverySalesLine(SalesOrderNo: Code[20]; customerNo: Code[20])
    begin
        ICExtended.CreateDeliverySalesLine(SalesOrderNo, customerNo);
        ICExtended.CreateItemChargeAssgnt(SalesOrderNo, customerNo);
    end;

    var
        ICExtended: codeunit "IC Extended";
        glShipStationSetup: Record "ShipStation Setup";
        testMode: Boolean;
        errCarrierIsNull: TextConst ENU = 'Not Carrier Into ShipStation In Order = %1', RUS = 'В Заказе = %1 ShipStation не оппределен Перевозчик';
        errServiceIsNull: TextConst ENU = 'Not Service Into ShipStation In Order = %1', RUS = 'В Заказе = %1 ShipStation не оппределен Сервис';
        errTotalGrossWeightIsZero: TextConst ENU = 'Total Gross Weight Order = %1\But Must Be > 0', RUS = 'Общий Брутто вес Заказа = %1\Должен быть > 0';
        lblAwaitingShipment: Label 'awaiting_shipment';
        lblShipped: Label 'shipped';
        confUpdateCarriersList: TextConst ENU = 'Update the list %1?', RUS = 'Обновить список %1?';
        msgCarriersListUpdated: TextConst ENU = '%1 list updated', RUS = 'Обновить список %1?';
        errorWhseShipNotExist: TextConst ENU = 'Warehouse Shipment is not Created for Sales Order = %1!', RUS = 'Для Заказа продажи = %1 не создана Складская отгрузка!';
        _shippedStatus: TextConst ENU = 'Shipped', RUS = 'Отгружен';
        _assemblededStatus: TextConst ENU = 'Assembled', RUS = 'Собран';
        globalToken: Text;
        firstToken: Text;
}