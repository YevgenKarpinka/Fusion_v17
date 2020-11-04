codeunit 50004 "Caption Mgt."
{
    Permissions = tabledata "Item Description" = r, tabledata "Tenant Media" = rimd;

    procedure GetRecordFiltersWithCaptions(locCust: Record Customer): Text;
    var
        Result: Text;
    begin
        Result := locCust.GetFilters;
        exit(Result);
    end;

    procedure GetRecordFiltersWithCaptionsPurchaseHeader(locPH: Record "Purchase Header"): Text;
    var
        Result: Text;
    begin
        Result := locPH.GetFilters;
        exit(Result);
    end;

    procedure GetItemAttributeValue(ItemAttributeName: Text[50]; ItemNo: Code[20]): Text
    var
        _ItemDescription: Record "Item Description";
    begin
        if _ItemDescription.Get(ItemNo) then
            case ItemAttributeName of
                'FDA Code':
                    exit(_ItemDescription."FDA Code");
                'HTS Code':
                    exit(_ItemDescription."HTS Code");
            end;
        exit('');
    end;

    procedure SaveStreamToFile(_streamText: Text; ToFileName: Variant)
    var
        tmpTenantMedia: Record "Tenant Media";
        _inStream: inStream;
        _outStream: outStream;
    begin
        tmpTenantMedia.Content.CreateOutStream(_OutStream, TextEncoding::UTF8);
        _outStream.WriteText(_streamText);
        tmpTenantMedia.Content.CreateInStream(_inStream, TextEncoding::UTF8);
        // ToFileName := 'SampleFile.txt';
        DownloadFromStream(_inStream, 'Export', '', 'All Files (*.*)|*.*', ToFileName);
    end;

    procedure FormatDateUS(Date2Format: Date): Text
    begin
        exit(Format(Date2Format, 0, '<Month,2>/<Day,2>/<Year4>'));
    end;

    procedure ItemTrackingEntryExist(ItemNo: Code[20]): Boolean
    var
        locItemLedgerEntry: Record "Item Ledger Entry";
    begin
        locItemLedgerEntry.SetCurrentKey("Item No.", Positive, "Remaining Quantity");
        locItemLedgerEntry.SetRange("Item No.", ItemNo);
        locItemLedgerEntry.SetRange(Positive, true);
        locItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
        if locItemLedgerEntry.IsEmpty then
            exit(false);
        exit(true);
    end;
}