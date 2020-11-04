page 50017 "ShipStation Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ShipStation Setup";
    CaptionML = ENU = 'ShipStation Setup', RUS = 'ShipStation настройка';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("ShipStation Integration Enable"; Rec."ShipStation Integration Enable")
                {
                    ApplicationArea = All;
                }
                field("Order Status Update"; Rec."Order Status Update")
                {
                    ApplicationArea = All;
                }
                field("Show Error"; Rec."Show Error")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateCarriers)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Update Carriers and Services',
                            RUS = 'Обновить услуги доставки';

                trigger OnAction()
                begin
                    ShipStationMgt.UpdateCarriersAndServices();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        isEditable := Rec."ShipStation Integration Enable";
    end;

    var
        ShipStationMgt: Codeunit "ShipStation Mgt.";
        isEditable: Boolean;
}