page 50002 "Shipping Rates Subpage"
{
    CaptionML = ENU = 'Shipping Rate Lines';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Shipping Agent Services";
    SourceTableView = where("Shipment Cost" = filter('<>0'));
    AccessByPermission = tabledata "Shipping Agent Services" = rimd;

    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("SS Code"; Rec."SS Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Shipment Cost"; Rec."Shipment Cost")
                {
                    ApplicationArea = All;
                }
                field("Other Cost"; Rec."Other Cost")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure GetAgentServiceCodes(var AgentCode: Code[10]; var ServiceCode: Code[10])
    begin
        AgentCode := Rec."Shipping Agent Code";
        ServiceCode := Rec.Code;
    end;

    procedure InitPage(_SAS: Record "Shipping Agent Services")
    begin
        Rec := _SAS;
    end;
}