codeunit 50011 "Item Tracking Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, codeunit::"Reservation Management", 'OnAutoReserveItemLedgEntryOnFindFirstItemLedgEntry', '', false, false)]
    local procedure AddExpirationDateKey(var CalcItemLedgEntry: Record "Item Ledger Entry"; var InvSearch: Text[1]; var IsHandled: Boolean; var IsFound: Boolean)
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        GetLocation(CalcItemLedgEntry.GetFilter("Location Code"));
        if Location."Pick According to FEFO" then begin
            CalcItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Expiration Date");
            if Item.get(CalcItemLedgEntry.GetFilter("Item No."))
                and (Item."Item Tracking Code" <> '')
                and ItemTrackingCode.Get(Item."Item Tracking Code")
                and ItemTrackingCode."Strict Expiration Posting" then
                CalcItemLedgEntry.SetFilter("Expiration Date", '%1..', Today);
            InvSearch := '-';
            IsFound := CalcItemLedgEntry.FIND(InvSearch);
            IsHandled := true;
        end;
    end;

    procedure GetItemTrackingSerialNo(ILE_EntryNo: Integer): Code[50]
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Serial No.")
        else
            exit('');
    end;

    procedure GetItemTrackingLotNo(ILE_EntryNo: Integer): Code[50]
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Lot No.")
        else
            exit('');
    end;

    procedure GetItemTrackingQty(ILE_EntryNo: Integer): Decimal
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry.Quantity * -1)
        else
            exit(0);
    end;

    procedure GetItemTrackingWarrantyDate(ILE_EntryNo: Integer): Date
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Warranty Date")
        else
            exit(0D);
    end;

    procedure GetItemTrackingExpirationDate(ILE_EntryNo: Integer): Date
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Expiration Date")
        else
            exit(0D);
    end;

    procedure GetItemTrackingExpirationDateByLotNo(LotNo: Code[50]; ItemNo: Code[20]): Date
    begin
        glItemLedgerEntry.SetCurrentKey("Item No.", "Lot No.");
        glItemLedgerEntry.SetRange("Item No.", ItemNo);
        glItemLedgerEntry.SetRange("Lot No.", LotNo);
        if glItemLedgerEntry.FindFirst() then
            exit(glItemLedgerEntry."Expiration Date");
        exit(0D);
    end;

    procedure GetItemTrackingWarrantyDateByLotNo(LotNo: Code[50]; ItemNo: Code[20]): Date
    begin
        glItemLedgerEntry.SetCurrentKey("Item No.", "Lot No.");
        glItemLedgerEntry.SetRange("Item No.", ItemNo);
        glItemLedgerEntry.SetRange("Lot No.", LotNo);
        if glItemLedgerEntry.FindFirst() then
            exit(glItemLedgerEntry."Warranty Date");
        exit(0D);
    end;

    local procedure GetILE(ILE_EntryNo: Integer): Boolean
    begin
        exit(glItemLedgerEntry.Get(ILE_EntryNo));
    end;

    // modify  "Whse.-Shpt Create Pick Avail" to "Whse.-Shpt Create Pick" after test
    [EventSubscriber(ObjectType::Report, Report::"Whse.-Shpt Create Pick Avail", 'OnBeforeSortWhseActivHeaders', '', true, true)]
    local procedure HandleHideNothingToHandleError(var FirstActivityNo: Code[20]; var LastActivityNo: Code[20]; var WhseActivHeader: Record "Warehouse Activity Header"; var HideNothingToHandleError: Boolean)
    var
        WhseMoveNo: Code[20];
    begin
        if AllCompletePicked(WhseActivHeader) then exit;
        if not Confirm(cnfCreateWahseMove, true) then exit;

        if WhseActivHeader.FindSet(false, false) then
            repeat
                if not CompletePicked(WhseActivHeader."No.") then begin
                    WhsePickToWhseMove(WhseActivHeader."No.", WhseMoveNo);
                    UpdateMoveLines(WhseMoveNo);
                    RenumberLines(WhseMoveNo);
                end;
                WhseActivHeader.Delete(true);
            until WhseActivHeader.Next() = 0;

        // to do update warehouse pick serial no. line

        FirstActivityNo := '';
        LastActivityNo := '';
        HideNothingToHandleError := true;
        Message(msgWhseMoveCreated, WhseMoveNo);
    end;

    local procedure RenumberLines(WhseMoveNo: Code[20]);
    var
        WhseMoveLine: Record "Warehouse Activity Line";
        WhseMoveLineToUpdate: Record "Warehouse Activity Line";
        LineNo: Integer;
        LineNumber: Integer;
    begin
        WhseMoveLineToUpdate.SetCurrentKey("Source Line No.", "Item No.", "Expiration Date");
        WhseMoveLineToUpdate.SetRange("Activity Type", WhseMoveLineToUpdate."Activity Type"::Movement);
        WhseMoveLineToUpdate.SetRange("No.", WhseMoveNo);
        if WhseMoveLineToUpdate.FindLast() then begin
            LineNo := 10000 * WhseMoveLineToUpdate.Count;
            repeat
                WhseMoveLine := WhseMoveLineToUpdate;
                WhseMoveLineToUpdate.DELETE;
                WhseMoveLineToUpdate := WhseMoveLine;
                WhseMoveLineToUpdate."Line No." := LineNo;
                WhseMoveLineToUpdate.INSERT;
                LineNo -= 10000;
            until WhseMoveLineToUpdate.Next(-1) = 0;
        end;
    end;

    local procedure UpdateMoveLines(WhseMoveNo: Code[20])
    var
        WhseMoveLine: Record "Warehouse Activity Line";
        WhseMoveLineForSplit: Record "Warehouse Activity Line";
        WhseMoveLineForSplitPlace: Record "Warehouse Activity Line";
        tempItem: Record Item temporary;
        ToBinCode: Code[20];
        ToZoneCode: Code[20];
        FromBinCode: Code[20];
        FromZoneCode: Code[20];
        PickFilter: Text[1024];
        PutAwayFilter: Text[1024];
        ReservationEntry: Record "Reservation Entry";
        ReservationEntryLotNo: Record "Reservation Entry";
        BinContent: Record "Bin Content";
        remQtytoMove: Decimal;
        remReservQauntity: Decimal;
        QtyAvailableToTake: Decimal;
        remWhseMoveQty: Decimal;
        EntriesExist: Boolean;
        BinCodeFilter: Text[1024];
    begin
        // create item list to whse move
        CreateTempItemList(WhseMoveNo, tempItem);

        if tempItem.FindFirst() then begin
            repeat
                // get ToBin from Action Take where Bin Code exist
                ToBinCode := '';
                ToZoneCode := '';
                // get pick filter
                PickFilter := CreatePick.GetBinTypeFilter(3);
                // get PutAway filter
                PutAwayFilter := CreatePick.GetBinTypeFilter(4);

                WhseMoveLine.SetCurrentKey("Action Type", "Bin Code", "Item No.");
                WhseMoveLine.SetRange("Activity Type", WhseMoveLine."Activity Type"::Movement);
                WhseMoveLine.SetRange("No.", WhseMoveNo);
                WhseMoveLine.SetRange("Action Type", WhseMoveLine."Action Type"::Take);
                WhseMoveLine.SetFilter("Bin Code", '<>%1', '');
                WhseMoveLine.SetRange("Item No.", tempItem."No.");
                if WhseMoveLine.FindSet(false, false) then begin
                    ToBinCode := WhseMoveLine."Bin Code";
                    ToZoneCode := WhseMoveLine."Zone Code";
                    repeat
                        // delete record completted for pick
                        DeleteWhseMoveLine(WhseMoveLine."No.", WhseMoveLine."Line No.");
                    until WhseMoveLine.Next() = 0;
                end else begin
                    WhseMoveLine.Reset();
                    WhseMoveLine.SetRange("Activity Type", WhseMoveLine."Activity Type"::Movement);
                    WhseMoveLine.SetRange("No.", WhseMoveNo);
                    WhseMoveLine.FindFirst();

                    // find empty toBin
                    Bin.SetCurrentKey("Bin Type Code");
                    Bin.SetRange("Location Code", WhseMoveLine."Location Code");
                    Bin.SetRange("Bin Type Code", PickFilter);
                    if BinCodeFilter <> '' then
                        Bin.SetFilter(Code, '<>%1', BinCodeFilter);
                    Bin.SetRange(Empty, true);
                    if not Bin.FindFirst() then
                        Error(errNoEmptyBinForPick, WhseMoveLine."Location Code", PickFilter);
                    ToBinCode := Bin.Code;
                    ToZoneCode := Bin."Zone Code";
                    // create Bin Code filter
                    CreateBinCodeFilter(BinCodeFilter, ToBinCode);
                end;

                // modify Place record
                WhseMoveLine.SetRange("Action Type", WhseMoveLine."Action Type"::Place);
                WhseMoveLine.SetFilter("Bin Code", '<>%1', '');
                WhseMoveLine.SetRange("Item No.", tempItem."No.");
                if WhseMoveLine.FindSet(false, true) then
                    repeat
                        WhseMoveLine.Validate("Zone Code", ToZoneCode);
                        WhseMoveLine.Validate("Bin Code", ToBinCode);
                        WhseMoveLine.Modify();
                    until WhseMoveLine.Next() = 0;

                WhseMoveLine.Reset();
                WhseMoveLine.SetRange("Activity Type", WhseMoveLine."Activity Type"::Movement);
                WhseMoveLine.SetRange("No.", WhseMoveNo);
                WhseMoveLine.SetRange("Action Type", WhseMoveLine."Action Type"::Take);
                WhseMoveLine.SetRange("Item No.", tempItem."No.");
                WhseMoveLine.FindSet(false, true);
                GetLocation(WhseMoveLine."Location Code");
                ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.");
                BinContent.SetCurrentKey("Location Code", "Item No.", "Variant Code", "Unit of Measure Code");
                remQtytoMove := tempItem."Budget Quantity";
                repeat
                    PlaceLineNo := WhseMoveLine."Line No." + 10000;
                    remWhseMoveQty := WhseMoveLine.Quantity;
                    ReservationEntry.SetRange("Source ID", WhseMoveLine."Source No.");
                    ReservationEntry.SetRange("Source Ref. No.", WhseMoveLine."Source Line No.");
                    if ReservationEntry.FindSet(false, false) then
                        repeat
                            ReservationEntryLotNo.Get(ReservationEntry."Entry No.", true);
                            if ReservationEntryLotNo."Item Tracking" = ReservationEntryLotNo."Item Tracking"::"Lot No." then begin
                                remReservQauntity := ReservationEntryLotNo.Quantity;
                                // find FromBin
                                BinContent.SetRange("Location Code", WhseMoveLine."Location Code");
                                BinContent.SetRange("Item No.", WhseMoveLine."Item No.");
                                BinContent.SetRange("Variant Code", WhseMoveLine."Variant Code");
                                BinContent.SetRange("Unit of Measure Code", WhseMoveLine."Unit of Measure Code");
                                BinContent.SetFilter("Lot No. Filter", ReservationEntryLotNo."Lot No.");
                                if BinContent.FindSet(false, false) then begin
                                    repeat
                                        QtyAvailableToTake := BinContent.CalcQtyAvailToTakeUOM();
                                        if (BinContent."Zone Code" = PutAwayFilter) and (QtyAvailableToTake > 0) then begin
                                            WhseMoveLine."Lot No." := ReservationEntryLotNo."Lot No.";
                                            WhseMoveLine."Expiration Date" := ItemTrackingMgt.ExistingExpirationDate(WhseMoveLine."Item No.", WhseMoveLine."Variant Code",
                                                ReservationEntryLotNo."Lot No.", '', false, EntriesExist);
                                            WhseMoveLine."Zone Code" := BinContent."Zone Code";
                                            WhseMoveLine."Bin Code" := BinContent."Bin Code";
                                            WhseMoveLine.Modify();
                                            UpdatePlaceLine(WhseMoveLine, ToZoneCode, ToBinCode);
                                            if QtyAvailableToTake > remReservQauntity then
                                                QtyAvailableToTake := remReservQauntity;

                                            if QtyAvailableToTake < remQtytoMove then begin
                                                if WhseMoveLine."Qty. to Handle" <> QtyAvailableToTake then begin
                                                    if WhseMoveLine."Qty. to Handle" > QtyAvailableToTake then begin
                                                        WhseMoveLine.Validate("Qty. to Handle", QtyAvailableToTake);
                                                        WhseMoveLine.Modify(true);
                                                    end;
                                                    if WhseMoveLine."Qty. to Handle" <> WhseMoveLine.Quantity then begin
                                                        // split Place line for remaining quantity
                                                        SplitPlaceLineForRemQty(WhseMoveLine);
                                                        // split Take line for remaining quantity
                                                        WhseMoveLineForSplit.Copy(WhseMoveLine);
                                                        WhseMoveLine.SplitLine(WhseMoveLineForSplit);
                                                        WhseMoveLine.Copy(WhseMoveLineForSplit);
                                                        WhseMoveLine.Next();
                                                        WhseMoveLine."Lot No." := '';
                                                        WhseMoveLine."Expiration Date" := 0D;
                                                        WhseMoveLine.Modify();
                                                    end;
                                                end;
                                            end;
                                            // calculate remaining qty
                                            remQtytoMove -= QtyAvailableToTake;
                                            remReservQauntity -= QtyAvailableToTake;
                                            remWhseMoveQty -= QtyAvailableToTake;
                                        end;
                                    until (BinContent.Next() = 0) or (remReservQauntity <= 0);
                                end;
                            end;
                        until (ReservationEntry.Next() = 0) or (remWhseMoveQty <= 0);
                until WhseMoveLine.Next() = 0;
            until tempItem.Next() = 0;
        end;
    end;

    local procedure CreateBinCodeFilter(var BinCodeFilter: Text[1024];
ToBinCode: Code[20])
    begin
        BinCodeFilter := ToBinCode + '|';
        BinCodeFilter := CopyStr(BinCodeFilter, 1, StrLen(BinCodeFilter) - 1);
    end;

    procedure SplitPlaceLine(var WhseActivLine: Record "Warehouse Activity Line")
    var
        NewWhseActivLine: Record "Warehouse Activity Line";
        LineSpacing: Integer;
        NewLineNo: Integer;
    begin
        NewWhseActivLine := WhseActivLine;
        NewWhseActivLine.SetRange("No.", WhseActivLine."No.");
        if NewWhseActivLine.Find('>') then
            LineSpacing :=
              (NewWhseActivLine."Line No." - WhseActivLine."Line No.") div 2
        else
            LineSpacing := 10000;

        if LineSpacing = 0 then begin
            ReNumberAllLines(NewWhseActivLine, WhseActivLine."Line No.", NewLineNo);
            WhseActivLine.Get(WhseActivLine."Activity Type", WhseActivLine."No.", NewLineNo);
            LineSpacing := 5000;
        end;

        NewWhseActivLine.Reset();
        NewWhseActivLine.Init();
        NewWhseActivLine := WhseActivLine;
        NewWhseActivLine."Line No." := NewWhseActivLine."Line No." + LineSpacing;
        NewWhseActivLine.Quantity :=
          WhseActivLine."Qty. Outstanding" - WhseActivLine."Qty. to Handle";
        NewWhseActivLine."Qty. (Base)" :=
          WhseActivLine."Qty. Outstanding (Base)" - WhseActivLine."Qty. to Handle (Base)";
        NewWhseActivLine."Qty. Outstanding" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. Outstanding (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. to Handle" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. to Handle (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. Handled" := 0;
        NewWhseActivLine."Qty. Handled (Base)" := 0;
        GetLocation(NewWhseActivLine."Location Code");
        if Location."Directed Put-away and Pick" then begin
            WMSMgt.CalcCubageAndWeight(
              NewWhseActivLine."Item No.", NewWhseActivLine."Unit of Measure Code",
              NewWhseActivLine."Qty. to Handle", NewWhseActivLine.Cubage, NewWhseActivLine.Weight);
        end;
        NewWhseActivLine."Lot No." := '';
        NewWhseActivLine."Expiration Date" := 0D;
        NewWhseActivLine.Insert();

        WhseActivLine.Quantity := WhseActivLine."Qty. to Handle" + WhseActivLine."Qty. Handled";
        WhseActivLine."Qty. (Base)" :=
          WhseActivLine."Qty. to Handle (Base)" + WhseActivLine."Qty. Handled (Base)";
        WhseActivLine."Qty. Outstanding" := WhseActivLine."Qty. to Handle";
        WhseActivLine."Qty. Outstanding (Base)" := WhseActivLine."Qty. to Handle (Base)";
        if Location."Directed Put-away and Pick" then
            WMSMgt.CalcCubageAndWeight(
              WhseActivLine."Item No.", WhseActivLine."Unit of Measure Code",
              WhseActivLine."Qty. to Handle", WhseActivLine.Cubage, WhseActivLine.Weight);
        WhseActivLine.Modify();

        PlaceLineNo := NewWhseActivLine."Line No.";
    end;

    local procedure ReNumberAllLines(var NewWhseActivityLine: Record "Warehouse Activity Line"; OldLineNo: Integer; var NewLineNo: Integer)
    var
        TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary;
        LineNo: Integer;
    begin
        NewWhseActivityLine.FindSet;
        repeat
            LineNo += 10000;
            TempWarehouseActivityLine := NewWhseActivityLine;
            TempWarehouseActivityLine."Line No." := LineNo;
            TempWarehouseActivityLine.Insert();
            if NewWhseActivityLine."Line No." = OldLineNo then
                NewLineNo := LineNo;
        until NewWhseActivityLine.Next = 0;
        NewWhseActivityLine.DeleteAll();

        TempWarehouseActivityLine.FindSet;
        repeat
            NewWhseActivityLine := TempWarehouseActivityLine;
            NewWhseActivityLine.Insert();
        until TempWarehouseActivityLine.Next = 0;
    end;

    local procedure UpdatePlaceLine(WhseMoveLine: Record "Warehouse Activity Line"; ToZoneCode: Code[10]; ToBinCode: Code[20])
    var
        WhseMoveLineForSplit: Record "Warehouse Activity Line";
    begin
        WhseMoveLineForSplit.Get(WhseMoveLine."Activity Type", WhseMoveLine."No.", PlaceLineNo);
        WhseMoveLineForSplit."Lot No." := WhseMoveLine."Lot No.";
        WhseMoveLineForSplit."Expiration Date" := WhseMoveLine."Expiration Date";
        WhseMoveLineForSplit."Zone Code" := ToZoneCode;
        WhseMoveLineForSplit."Bin Code" := ToBinCode;
        WhseMoveLineForSplit.Modify();
    end;

    local procedure SplitPlaceLineForRemQty(WhseMoveLine: Record "Warehouse Activity Line")
    var
        WhseMoveLineForSplit: Record "Warehouse Activity Line";
    begin
        WhseMoveLineForSplit.Get(WhseMoveLine."Activity Type", WhseMoveLine."No.", PlaceLineNo);
        WhseMoveLineForSplit.Validate("Qty. to Handle", WhseMoveLine."Qty. to Handle");
        WhseMoveLineForSplit.Modify(true);
        SplitPlaceLine(WhseMoveLineForSplit);
    end;

    local procedure DeleteWhseMoveLine(WhseMoveNo: Code[20]; LineNo: Integer)
    var
        WhseMoveLine: Record "Warehouse Activity Line";
    begin
        WhseMoveLine.SetRange("Activity Type", WhseMoveLine."Activity Type"::Movement);
        WhseMoveLine.SetRange("No.", WhseMoveNo);
        WhseMoveLine.SetRange("Line No.", LineNo, LineNo + 10000);
        WhseMoveLine.Ascending(false);
        if WhseMoveLine.FindSet(false, false) then
            repeat
                WhseMoveLine.Delete(); // to ensure correct item tracking update
                WhseMoveLine.DeleteBinContent(WhseMoveLine."Action Type"::Place);
                WhseMoveLine.UpdateRelatedItemTrkg(WhseMoveLine);
            until WhseMoveLine.Next() = 0;
    end;

    local procedure CreateTempItemList(WhseMoveNo: Code[20]; var tempItem: Record Item temporary)
    var
        WhseMoveLine: Record "Warehouse Activity Line";
    begin
        WhseMoveLine.SetCurrentKey("Action Type", "Bin Code", "Item No.");
        WhseMoveLine.SetRange("Activity Type", WhseMoveLine."Activity Type"::Movement);
        WhseMoveLine.SetRange("No.", WhseMoveNo);
        WhseMoveLine.SetRange("Action Type", WhseMoveLine."Action Type"::Take);
        WhseMoveLine.SetRange("Bin Code", '');
        if WhseMoveLine.FindSet(false, false) then
            repeat
                if not tempItem.Get(WhseMoveLine."Item No.") then begin
                    tempItem."No." := WhseMoveLine."Item No.";
                    tempItem.Insert();
                end;
            until WhseMoveLine.Next() = 0;

        if tempItem.FindSet(false, false) then
            repeat
                WhseMoveLine.SetRange("Bin Code");
                WhseMoveLine.SetRange("Item No.", tempItem."No.");
                if WhseMoveLine.FindSet(false, false) then begin
                    WhseMoveLine.CalcSums(Quantity);
                    tempItem."Budget Quantity" := WhseMoveLine.Quantity;
                    tempItem.Modify();
                end;
            until tempItem.Next() = 0;
    end;

    procedure GetLocation(LocationCode: Code[10])
    begin
        IF Location.Code <> LocationCode THEN BEGIN
            IF LocationCode = '' THEN
                Location.GetLocationSetup(LocationCode, Location)
            ELSE
                Location.GET(LocationCode);
        END;
    end;

    local procedure AllCompletePicked(var WhsePickHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhsePickLine: Record "Warehouse Activity Line";
    begin
        if WhsePickHeader.FindFirst() then begin
            GetLocation(WhsePickHeader."Location Code");
            if not Location."Create Move" then exit(true);
        end else
            exit(true);

        repeat
            WhsePickLine.SetCurrentKey("Shipping Advice");
            WhsePickLine.SetRange("Activity Type", WhsePickHeader.Type);
            WhsePickLine.SetRange("No.", WhsePickHeader."No.");
            WhsePickLine.SetRange("Action Type", WhsePickLine."Action Type"::Take);
            WhsePickLine.SetRange("Bin Code", '');
            exit(WhsePickLine.IsEmpty);
        until WhsePickHeader.Next() = 0;
        exit(true);
    end;

    local procedure CompletePicked(WhsePickNo: Code[20]): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.SetCurrentKey("Shipping Advice");
        WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::Pick);
        WhseActivLine.SetRange("No.", WhsePickNo);
        WhseActivLine.SetRange("Action Type", WhseActivLine."Action Type"::Take);
        WhseActivLine.SetRange("Bin Code", '');
        exit(WhseActivLine.IsEmpty);
    end;

    local procedure WhsePickToWhseMove(WhsePickNo: Code[20]; var WhseMoveNo: code[20])
    var
        WhsePickHeader: Record "Warehouse Activity Header";
        WhsePickLine: Record "Warehouse Activity Line";
        WhseMoveHeader: Record "Warehouse Activity Header";
        WhseMoveLine: Record "Warehouse Activity Line";
    begin
        WhsePickHeader.Get(WhseMoveHeader.Type::Pick, WhsePickNo);
        WhseMoveHeader.Init();
        WhseMoveHeader.TransferFields(WhsePickHeader);
        WhseMoveHeader.Type := WhseMoveHeader.Type::Movement;
        WhseMoveHeader."No." := '';
        WhseMoveHeader.Insert(true);

        WhsePickLine.SetRange("Activity Type", WhsePickLine."Activity Type"::Pick);
        WhsePickLine.SetRange("No.", WhsePickNo);
        WhsePickLine.FindSet(false, false);
        repeat
            WhseMoveLine.Init();
            WhseMoveLine.TransferFields(WhsePickLine);
            WhseMoveLine."Activity Type" := WhsePickLine."Activity Type"::Movement;
            WhseMoveLine."No." := WhseMoveHeader."No.";
            WhseMoveLine.Insert(true);
        until WhsePickLine.Next() = 0;
        WhseMoveNo := WhseMoveHeader."No.";
    end;

    var
        glItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
        Bin: Record Bin;
        BinType: Record "Bin Type";
        CreatePick: Codeunit "Create Pick";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseAvailMgt: Codeunit "Warehouse Availability Mgt.";
        WMSMgt: Codeunit "WMS Management";
        PlaceLineNo: Integer;
        msgWhseMoveCreated: TextConst ENU = 'Warehouse Movement %1 created.',
                                      RUS = 'Складское передвижение %1 создано.';
        cnfCreateWahseMove: TextConst ENU = 'Create Warehouse Movement?',
                                      RUS = 'Создать Складское передвижение?';
        errNoEmptyBinForPick: TextConst ENU = 'No Empty Bin For Pick. Location %1. Zona %2.',
                                      RUS = 'Нет свбодных ячеек для подбора. Склад %1. Зона %2.';
}