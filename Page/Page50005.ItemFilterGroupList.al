page 50005 "Item Filter Group List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Item Filter Group";
    AccessByPermission = tabledata "Item Filter Group" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = IsEditable;
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Visible = visibleItemNo;
                }
                field(FilterGroup; Rec."Filter Group")
                {
                    ApplicationArea = All;
                    Visible = visibleGroup;
                }
                field(FilterValue; Rec."Filter Value")
                {
                    ApplicationArea = All;
                    Visible = visibleValue;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if (Rec.GetFilters() = '') or IsEditable then begin
            visibleItemNo := true;
            visibleGroup := true;
            visibleValue := true;
            IsEditable := true;
            exit;
        end;

        // visibleItemNo := (GetFilter("Item No.") <> '') or (GetFilter("Filter Group") <> '') or (GetFilter("Filter Value") <> '');
        visibleGroup := (Rec.GetFilter("Filter Group") <> '') or (Rec.GetFilter("Filter Value") <> '');
        visibleValue := (Rec.GetFilter("Filter Value") <> '');
        IsEditable := false;

        Rec.Reset();
        Rec.FindFirst();
    end;

    procedure SetInit(_isEditable: Boolean)
    begin
        IsEditable := _isEditable;
    end;

    var
        IsEditable: Boolean;
        visibleItemNo: Boolean;
        visibleGroup: Boolean;
        visibleValue: Boolean;
}