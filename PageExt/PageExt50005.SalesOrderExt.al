pageextension 50005 "Sales Order Ext." extends "Sales Order"
{
    layout
    {
        // Add changes to page layout here
        addfirst(factboxes)
        {
            // part(ItemTrackingEntries; "Item Tracking Entries FactBox")
            // {
            //     ApplicationArea = Basic, Suite;
            //     Provider = SalesLines;
            //     SubPageLink = "Item No." = field("No."), "Location Code" = field("Location Code"), "Variant Code" = field("Variant Code"), "Unit of Measure Code" = field("Unit of Measure Code");
            //     SubPageView = sorting("Expiration Date") where(Open = const(true), Positive = const(true));
            // }
            part(ItemBinContent; "Item Bin Content FactBox")
            {
                ApplicationArea = Basic, Suite;
                Provider = SalesLines;
                SubPageLink = "Item No." = field("No."), "Location Code" = field("Location Code"), "Variant Code" = field("Variant Code"), "Unit of Measure Code" = field("Unit of Measure Code");
                SubPageView = sorting("Expiration Date") where(Open = const(true), Positive = const(true));
            }
            part(ItemTrackingLine; "Item Tracking Line FactBox")
            {
                ApplicationArea = Basic, Suite;
                Provider = SalesLines;
                SubPageLink = "Item No." = field("No."), "Source ID" = field("Document No."), "Source Ref. No." = field("Line No.");
            }
        }
        addafter(Status)
        {
            field("IC Document No."; "IC Document No.")
            {
                Importance = Additional;
                ApplicationArea = All;
                Editable = false;
            }
            field("Gross Weight"; ShipStationMgt.CalculateSalesOrderGrossWeight("No."))
            {
                Importance = Promoted;
                ApplicationArea = All;
            }
        }
        addafter("Shipping Agent Code")
        {
            field("Agent Name"; GetShippingAgentName("Shipping Agent Code"))
            {
                Importance = Additional;
                ApplicationArea = All;
                Style = Strong;
            }
        }
        addafter("Shipping Agent Service Code")
        {
            field("Service Description"; GetShippingAgentServiceDescription("Shipping Agent Code", "Shipping Agent Service Code"))
            {
                Importance = Additional;
                ApplicationArea = All;
                Style = Strong;
            }
        }
        addafter(Control1900201301)
        {
            group(groupShipStation)
            {
                CaptionML = ENU = 'ShipStation', RUS = 'ShipStation';

                field("ShipStation Order ID"; "ShipStation Order ID")
                {
                    ApplicationArea = All;

                }
                field("ShipStation Order Key"; "ShipStation Order Key")
                {
                    ApplicationArea = All;

                }
                field("ShipStation Status"; "ShipStation Status")
                {
                    ApplicationArea = All;

                }
                field("ShipStation Shipment Amount"; "ShipStation Shipment Amount")
                {
                    ApplicationArea = All;

                }
                field("ShipStation Shipment Cost"; "ShipStation Shipment Cost")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("ShipStation Insurance Cost"; "ShipStation Insurance Cost")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("ShipStation Shipment ID"; "ShipStation Shipment ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("Warehouse Shipment Lines")
        {
            action(PickLines)
            {
                ApplicationArea = Warehouse;
                Image = PickLines;
                CaptionML = ENU = 'Pick Lines', RUS = 'Строки подбора';
                ToolTipML = ENU = 'View the related picks.', RUS = 'Просмотр связанных подборов.';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Warehouse Activity Lines";
                RunPageView = SORTING("Whse. Document No.", "Whse. Document Type", "Activity Type") WHERE("Activity Type" = CONST(Pick));
                RunPageLink = "Source Document" = CONST("Sales Order"), "Source No." = FIELD("No.");
            }
        }
        addafter("Pick Instruction")
        {
            action("Sales Order Fusion")
            {
                ApplicationArea = All;
                Image = PrintReport;
                CaptionML = ENU = 'Sales Order Fusion', RUS = 'Заказ продажи Fusion';

                trigger OnAction()
                var
                    _SalesHeader: Record "Sales Header";
                begin
                    _SalesHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(_SalesHeader);
                    Report.Run(Report::"Sales Order Fusion", true, true, _SalesHeader);
                end;
            }
        }
        addafter(IncomingDocument)
        {
            action("Delete IC Sales and Purchase Orders")
            {
                ApplicationArea = All;
                Image = DeleteAllBreakpoints;
                CaptionML = ENU = 'Delete IC Sales and Purchase Orders', RUS = 'Удалить МФ Заказы Продажи и Покупки';

                trigger OnAction()
                var
                    _SalesHeader: Record "Sales Header";
                    _ICExtended: Codeunit "IC Extended";
                begin
                    _SalesHeader := Rec;
                    _ICExtended.DeletePurchOrderAndICSalesOrder(_SalesHeader);
                end;
            }
        }
        addbefore("F&unctions")
        {
            group(actionShipStation)
            {
                CaptionML = ENU = 'ShipStation', RUS = 'ShipStation';
                Image = ReleaseShipment;

                action("Create/Update Order")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Order', RUS = 'Создать Заказ';
                    Image = CreateDocuments;
                    Visible = (Status = Status::Released)
                                and ("ShipStation Shipment ID" = '');

                    trigger OnAction()
                    var
                        _SH: Record "Sales Header";
                        lblOrderCreated: TextConst ENU = 'Order Created in ShipStation!', RUS = 'Заказ в ShipStation создан!';
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.CreateOrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblOrderCreated);
                    end;
                }
                action("Get Rates")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Get Rates', RUS = 'Получить Стоимость';
                    Image = CalculateShipment;
                    // Visible = Status = Status::Open;
                    Visible = false;

                    trigger OnAction()
                    var
                        recSAS: Record "Shipping Agent Services";
                        pageShippingRates: Page "Shipping Rates";
                        SSMgt: Codeunit "ShipStation Mgt.";
                    begin
                        // if "ShipStation Order Key" = '' then Error(salesOrderNotRegisterInShipStation, "No.");
                        SSMgt.GetShippingRatesByCarrier(Rec);
                        Commit();
                        pageShippingRates.LookupMode(true);
                        if pageShippingRates.RunModal() = Action::LookupOK then begin
                            pageShippingRates.GetAgentServiceCodes(recSAS);
                            UpdateAgentServiceRateSalesHeader(recSAS);
                            // Message('Service %1', recSAS."SS Code");
                        end;
                    end;
                }
                action("Create Label")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Label', RUS = 'Создать бирку';
                    Image = PrintReport;
                    Visible = ("ShipStation Order ID" <> '')
                                and ("ShipStation Shipment ID" = '')
                                and (Status = Status::Released);

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblLabelCreated: TextConst ENU = 'Label Created and Attached to Warehouse Shipment!',
                                                    RUS = 'Бирка создана и прикреплена к Отгрузке!';
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.CreateLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblLabelCreated);
                    end;
                }
                action("Void Label")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Void Label', RUS = 'Отменить бирку';
                    Image = VoidCreditCard;
                    Visible = ("ShipStation Shipment ID" <> '') and ("ShipStation Order ID" <> '');

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblLabelVoided: TextConst ENU = 'Label Voided!',
                                                  RUS = 'Бирка отменена!';
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.VoidLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblLabelVoided);
                    end;
                }
            }
        }
    }

    var
        ShipStationMgt: Codeunit "ShipStation Mgt.";
        salesOrderNotRegisterInShipStation: TextConst ENU = 'Sales Order %1 Not Register In ShipStation', RUS = 'Заказ Продажи %1 не зарегистророван в ShipStation';

}