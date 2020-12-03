codeunit 50012 "Transfer Items To Site Mgt"
{
    trigger OnRun()
    begin
        TransferItemsToSite();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CaptionMgt: Codeunit "Caption Mgt.";
        IsSuccessStatusCode: Boolean;

    local procedure TransferItemsToSite()
    var
        ShipStationMgt: Codeunit "ShipStation Mgt.";
        _jsonItemList: JsonArray;
        _jsonErrorItemList: JsonArray;
        _jsonItem: JsonObject;
        _jsonToken: JsonToken;
        _jsonText: Text;
        TotalCount: Integer;
        Counter: Integer;
        responseText: Text;
        ItemTransferList: Record "Item Transfer Site";
    begin
        ItemTransferList.Reset();
        Counter := 0;
        TotalCount := ItemTransferList.Count;

        if ItemTransferList.FindSet(false, false) then
            repeat
                _jsonItem := ShipStationMgt.CreateJsonItemForWooComerse(ItemTransferList."Item No.");
                Counter += 1;

                if _jsonItem.Get('SKU', _jsonToken) then begin
                    _jsonItemList.Add(_jsonItem);

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
                    DeleteItemForTransferToSite(ItemTransferList."Item No.");
                end;
            until ItemTransferList.Next() = 0;
        GetGLSetup();
        if (_jsonErrorItemList.Count > 0)
        and GLSetup."Save Error To File" then begin
            _jsonErrorItemList.WriteTo(_jsonText);
            CaptionMgt.SaveStreamToFile(_jsonText, 'errorItemList.txt');
        end;
    end;

    local procedure MarkItemToTransfer(ItemNoFilter: Text)
    var
        ItemModify: Record Item;
    begin
        ItemModify.SetFilter("No.", ItemNoFilter);
        if ItemModify.FindSet(false, true) then
            repeat
                if ItemModify."Web Item" then begin
                    ItemModify."Transfered to eShop" := false;
                    ItemModify.Modify();
                end;
            until ItemModify.Next() = 0;
    end;

    procedure AddAllItemsForTransferToSite()
    var
        ItemForTransfer: Record Item;
    begin
        ItemForTransfer.SetCurrentKey("Web Item");
        ItemForTransfer.SetRange("Web Item", true);
        if ItemForTransfer.FindSet(false, false) then
            repeat
                AddItemForTransferToSite(ItemForTransfer."No.");
            until ItemForTransfer.Next() = 0;
    end;

    procedure AddItemForTransferToSite(ItemNoFilter: Text)
    var
        ItemForTransfer: Record Item;
        ItemTransferList: Record "Item Transfer Site";
    begin
        GetGLSetup();
        if not GLSetup."Transfer Items Allowed" then exit;

        ItemForTransfer.SetFilter("No.", ItemNoFilter);
        if ItemForTransfer.FindSet(false, true) then
            repeat
                if ItemForTransfer."Web Item" then
                    if not ItemTransferList.Get(ItemForTransfer."No.") then begin
                        ItemTransferList.Init();
                        ItemTransferList."Item No." := ItemForTransfer."No.";
                        ItemTransferList.Insert();
                    end;
            until ItemForTransfer.Next() = 0;
    end;

    local procedure DeleteItemForTransferToSite(ItemNoFilter: Text)
    var
        ItemTransferList: Record "Item Transfer Site";
    begin
        ItemTransferList.SetFilter("Item No.", ItemNoFilter);
        ItemTransferList.DeleteAll();
    end;

    local procedure GetGLSetup();
    begin
        GLSetup.Get;
    end;

    // transfer item after purchase post
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRunOnBeforeFinalizePosting', '', false, false)]
    local procedure OnTransferItemToSiteAfterPurchPost(var PurchaseHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        ItemNoFilter: Text;
    begin
        PurchLine.SetCurrentKey(Type, Quantity);
        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter(Quantity, '<>%1', 0);
        if PurchLine.FindSet(false, false) then begin
            repeat
                ItemNoFilter += '|' + PurchLine."No.";
            until PurchLine.Next() = 0;
            ItemNoFilter := CopyStr(ItemNoFilter, 2, StrLen(ItemNoFilter));
            GetGLSetup();
            if not GLSetup."Transfer Items Job Queue Only" then
                OnTransferItemToSite(ItemNoFilter)
            else
                // MarkItemToTransfer(ItemNoFilter);
                AddItemForTransferToSite(ItemNoFilter);
        end;
    end;

    // transfer item after sales post
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnRunOnBeforeFinalizePosting', '', false, false)]
    local procedure OnTransferItemToSiteAfterSalePost(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ItemNoFilter: Text;
    begin
        SalesLine.SetCurrentKey(Type, Quantity);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        if SalesLine.FindSet(false, false) then begin
            repeat
                ItemNoFilter += '|' + SalesLine."No.";
            until SalesLine.Next() = 0;
            ItemNoFilter := CopyStr(ItemNoFilter, 2, StrLen(ItemNoFilter));
            GetGLSetup();
            if not GLSetup."Transfer Items Job Queue Only" then
                OnTransferItemToSite(ItemNoFilter)
            else
                // MarkItemToTransfer(ItemNoFilter);
                AddItemForTransferToSite(ItemNoFilter);
        end;
    end;

    // transfer item after manual reserve
    [EventSubscriber(ObjectType::Page, Page::Reservation, 'OnAfterUpdateReservFrom', '', false, false)]
    local procedure OnTransferItemToSiteAfterManualReserve(var EntrySummary: Record "Entry Summary")
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        if ReservationEntry.Get(EntrySummary."Entry No.") then
            if (ReservationEntry."Reservation Status" = ReservationEntry."Reservation Status"::Reservation) then begin
                GetGLSetup();
                if not GLSetup."Transfer Items Job Queue Only" then
                    OnTransferItemToSite(ReservationEntry."Item No.")
                else
                    // MarkItemToTransfer(ReservationEntry."Item No.");
                    AddItemForTransferToSite(ReservationEntry."Item No.");
            end;
    end;

    // transfer item after auto reserve
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnAfterAutoReserve', '', false, false)]
    local procedure OnTransferItemToSiteAfterAutoReserve(var ReservationEntry: Record "Reservation Entry"; var FullAutoReservation: Boolean)
    begin
        if FullAutoReservation then begin
            GetGLSetup();
            if not GLSetup."Transfer Items Job Queue Only" then
                OnTransferItemToSite(ReservationEntry."Item No.")
            else
                // MarkItemToTransfer(ReservationEntry."Item No.");
                AddItemForTransferToSite(ReservationEntry."Item No.");
        end;
    end;

    // transfer item Before Delete Reserve Entries
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnBeforeDeleteReservEntries', '', false, false)]
    local procedure OnTransferItemToSiteBeforeDeleteReserve(var ReservationEntry: Record "Reservation Entry")
    begin
        if (ReservationEntry."Reservation Status" = ReservationEntry."Reservation Status"::Reservation) then begin
            GetGLSetup();
            if not GLSetup."Transfer Items Job Queue Only" then
                OnTransferItemToSite(ReservationEntry."Item No.")
            else
                // MarkItemToTransfer(ReservationEntry."Item No.");
                AddItemForTransferToSite(ReservationEntry."Item No.");
        end;
    end;

    local procedure OnTransferItemToSite(ItemNoFilter: Text)
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
        GetGLSetup();
        if not GLSetup."Transfer Items Allowed" then exit;

        _Item.SetCurrentKey("Web Item");
        _Item.SetFilter("No.", ItemNoFilter);
        _Item.SetRange("Web Item", true);

        Counter := 0;
        TotalCount := _Item.Count;

        if _Item.FindSet(false, false) then
            repeat
                _jsonItem := ShipStationMgt.CreateJsonItemForWooComerse(_Item."No.");
                Counter += 1;
                if _jsonItem.Get('SKU', _jsonToken) then begin
                    _jsonItemList.Add(_jsonItem);


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

        GetGLSetup();
        if (_jsonErrorItemList.Count > 0)
        and GLSetup."Save Error To File" then begin
            _jsonErrorItemList.WriteTo(_jsonText);
            CaptionMgt.SaveStreamToFile(_jsonText, 'errorItemList.txt');
        end;
    end;
}