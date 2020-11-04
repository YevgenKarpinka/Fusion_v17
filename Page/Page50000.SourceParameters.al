page 50000 "Source Parameters"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Source Parameters";
    SourceTableView = sorting(Code) order(descending);
    AccessByPermission = tabledata "Source Parameters" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("FSp Event"; Rec."FSp Event")
                {
                    ApplicationArea = All;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field("FSp RestMethod"; Rec."FSp RestMethod")
                {
                    ApplicationArea = All;
                }
                field("FSp URL"; Rec."FSp URL")
                {
                    ApplicationArea = All;
                }
                field("FSp UserName"; Rec."FSp UserName")
                {
                    ApplicationArea = All;
                }
                field("FSp Password"; Rec."FSp Password")
                {
                    ApplicationArea = All;
                }
                field("FSp AuthorizationFrameworkType"; Rec."FSp AuthorizationFrameworkType")
                {
                    ApplicationArea = All;
                }
                field("FSp AuthorizationToken"; Rec."FSp AuthorizationToken")
                {
                    ApplicationArea = All;
                }
                field("FSp ContentType"; Rec."FSp ContentType")
                {
                    ApplicationArea = All;
                }
                field("FSp ETag"; Rec."FSp ETag")
                {
                    ApplicationArea = All;
                }
                field("FSp Accept"; Rec."FSp Accept")
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
            action("Test Connection")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Test Connection', RUS = 'Тестовое подключение';

                trigger OnAction()
                var
                    ShipStationMgt: Codeunit "ShipStation Mgt.";
                begin
                    ShipStationMgt.Connect2ShipStation(1, '', '');
                    Message('Connection Ok!');
                end;
            }
            action("Test Connection2eShop")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Test Connection2eShop', RUS = 'Тестовое подключение к eShop';

                trigger OnAction()
                var
                    ShipStationMgt: Codeunit "ShipStation Mgt.";
                    IsSuccessStatusCode: Boolean;
                    responseText: Text;
                begin
                    responseText := ShipStationMgt.Connect2eShop('LOGIN2ESHOP', '', '', IsSuccessStatusCode);
                    if IsSuccessStatusCode then
                        Message('Connection2eShop Ok!')
                    else
                        Error(responseText);
                end;
            }
        }
    }
}