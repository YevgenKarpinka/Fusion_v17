page 50012 "Item Filter By Group"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Item Filter Group";
    AccessByPermission = tabledata "Item Filter Group" = r;

    layout
    {
        area(Content)
        {
            field(filterByItemNo; filterByItemNo)
            {
                ApplicationArea = Basic, Suite;
                CaptionML = ENU = 'Filter By Item No.', RUS = 'Фильтр по Товару';
                Lookup = true;
                Visible = false;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    codItemFilterByGroupMgt.OnLookUpItemNo(filterByItemNo, Rec);
                    setFilters();
                end;

                trigger OnValidate()
                begin
                    setFilters();
                end;
            }
            field(filterByGroup; filterByGroup)
            {
                ApplicationArea = Basic, Suite;
                CaptionML = ENU = 'Filter By Group', RUS = 'Фильтр по Группе';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    codItemFilterByGroupMgt.OnLookUpGroup(filterByGroup, Rec);
                    setFilters();
                end;

                trigger OnValidate()
                begin
                    setFilters();
                end;
            }
            field(filterByValue; filterByValue)
            {
                ApplicationArea = Basic, Suite;
                CaptionML = ENU = 'Filter By Value', RUS = 'Фильтр по Значению';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    codItemFilterByGroupMgt.OnLookUpValue(filterByValue, Rec);
                    setFilters();
                end;

                trigger OnValidate()
                begin
                    setFilters();
                end;

            }
            repeater(RepeaterName)
            {
                Editable = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Filter Group"; Rec."Filter Group")
                {
                    ApplicationArea = All;
                }
                field("Filter Value"; Rec."Filter Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnClosePage()
    var
        item: Record Item;
        tempItem: Record Item temporary;
    begin
        Rec.FindSet();
        repeat
            if item.Get(Rec."Item No.") then begin
                tempItem.TransferFields(item);
                if tempItem.Insert() then;
            end;
        until Rec.Next() = 0;

        glParameterCount := tempItem.Count;
        tempItem.FindSet(false, false);
        repeat
            glFilterItems += StrSubstNo('%1|', tempItem."No.");
        until tempItem.NEXT = 0;
        glFilterItems := CopyStr(glFilterItems, 1, StrLen(glFilterItems) - 1)
    end;

    procedure GetFilterItems(var parameterCount: Integer): Text
    begin
        parameterCount := glParameterCount;
        exit(glfilterItems);
    end;

    local procedure setFilters()
    begin
        Rec.ClearMarks();
        Rec.Reset();
        Rec.FilterGroup(0);
        if filterByItemNo <> '' then
            Rec.SetFilter("Item No.", filterByItemNo);

        if filterByGroup <> '' then
            Rec.SetFilter("Filter Group", filterByGroup);

        if filterByValue <> '' then
            Rec.SetFilter("Filter Value", filterByValue);

        CurrPage.Update(false);
    end;

    var
        codItemFilterByGroupMgt: Codeunit "Item Filter Group Mgt.";
        glParameterCount: Integer;
        filterByItemNo: Text;
        filterByGroup: Text;
        filterByValue: Text;
        glfilterItems: Text;
}