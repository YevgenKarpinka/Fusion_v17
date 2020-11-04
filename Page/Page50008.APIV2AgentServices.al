page 50008 "APIV2 - Agent Services"
{
    PageType = API;
    Caption = 'agentServices', Locked = true;
    APIPublisher = 'tcomtech';
    APIGroup = 'app';
    APIVersion = 'v1.0';
    EntityName = 'agentService';
    EntitySetName = 'agentServices';
    SourceTable = "Shipping Agent Services";
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(agentServicesId; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'agentServicesId', Locked = true;
                }
                field(serviceCode; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'serviceCode', Locked = true;
                }
                field(agentCode; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'agentCode', Locked = true;
                }
                field(description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'description', Locked = true;
                }
                field(ssCarrierCode; Rec."SS Carrier Code")
                {
                    ApplicationArea = All;
                    Caption = 'ssCarrierCode', Locked = true;
                }
                field(ssCode; Rec."SS Code")
                {
                    ApplicationArea = All;
                    Caption = 'ssCode', Locked = true;
                }
            }
        }
    }
}