page 50010 "APIV2 - Sales Orders"
{
    APIPublisher = 'tcomtech';
    APIGroup = 'app';
    APIVersion = 'v1.0';
    Caption = 'salesOrders', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'salesOrder';
    EntitySetName = 'salesOrders';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Sales Order Entity Buffer";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO(Id));
                    end;
                }
                field(number; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'number', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("No."));
                    end;
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'externalDocumentNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("External Document No."))
                    end;
                }
                field(orderDate; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'orderDate', Locked = true;

                    trigger OnValidate()
                    begin
                        DocumentDateVar := Rec."Document Date";
                        DocumentDateSet := TRUE;

                        RegisterFieldSet(Rec.FIELDNO("Document Date"));
                    end;
                }
                // >>
                field(shipstationShipmentAmount; Rec."ShipStation Shipment Amount")
                {
                    ApplicationArea = All;
                    Caption = 'shipstationShipmentAmount', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("ShipStation Shipment Amount"));
                    end;
                }
                // <<
                field(customerId; Rec."Customer Id")
                {
                    ApplicationArea = All;
                    Caption = 'customerId', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        SellToCustomer.SETRANGE(SystemId, Rec."Customer Id");
                        IF NOT SellToCustomer.FINDFIRST() THEN
                            ERROR(CouldNotFindSellToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(SellToCustomer);

                        Rec."Sell-to Customer No." := SellToCustomer."No.";
                        RegisterFieldSet(Rec.FIELDNO("Customer Id"));
                        RegisterFieldSet(Rec.FIELDNO("Sell-to Customer No."));
                    end;
                }
                field(contactId; Rec."Contact Graph Id")
                {
                    ApplicationArea = All;
                    Caption = 'contactId', Locked = true;

                    trigger OnValidate()
                    var
                        Contact: Record "Contact";
                        Customer: Record "Customer";
                        GraphIntContact: Codeunit "Graph Int. - Contact";
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Contact Graph Id"));

                        IF Rec."Contact Graph Id" = '' THEN
                            ERROR(SellToContactIdHasToHaveValueErr);

                        IF NOT GraphIntContact.FindOrCreateCustomerFromGraphContactSafe(Rec."Contact Graph Id", Customer, Contact) THEN
                            EXIT;

                        UpdateSellToCustomerFromSellToGraphContactId(Customer);

                        IF Contact."Company No." = Customer."No." THEN BEGIN
                            Rec.VALIDATE("Sell-To Contact No.", Contact."No.");
                            Rec.VALIDATE("Sell-to Contact", Contact.Name);

                            RegisterFieldSet(Rec.FIELDNO("Sell-To Contact No."));
                            RegisterFieldSet(Rec.FIELDNO("Sell-to Contact"));
                        END;
                    end;
                }
                field(customerNumber; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'customerNumber', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        IF SellToCustomer."No." <> '' THEN BEGIN
                            IF SellToCustomer."No." <> Rec."Sell-to Customer No." THEN
                                ERROR(SellToCustomerValuesDontMatchErr);
                            EXIT;
                        END;

                        IF NOT SellToCustomer.GET(Rec."Sell-to Customer No.") THEN
                            ERROR(CouldNotFindSellToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(SellToCustomer);

                        Rec."Customer Id" := SellToCustomer.SystemId;
                        RegisterFieldSet(Rec.FIELDNO(Rec."Customer Id"));
                        RegisterFieldSet(Rec.FIELDNO("Sell-to Customer No."));
                    end;
                }
                field(customerName; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'customerName', Locked = true;
                    Editable = false;
                }
                field(billToName; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                    Caption = 'billToName', Locked = true;
                    Editable = false;
                }
                field(billToCustomerId; Rec."Bill-to Customer Id")
                {
                    ApplicationArea = All;
                    Caption = 'billToCustomerId', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        BillToCustomer.SETRANGE(SystemId, Rec."Bill-to Customer Id");
                        IF NOT BillToCustomer.FINDFIRST() THEN
                            ERROR(CouldNotFindBillToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(BillToCustomer);

                        Rec."Bill-to Customer No." := BillToCustomer."No.";
                        RegisterFieldSet(Rec.FIELDNO("Bill-to Customer Id"));
                        RegisterFieldSet(Rec.FIELDNO("Bill-to Customer No."));
                    end;
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'billToCustomerNumber', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        IF BillToCustomer."No." <> '' THEN BEGIN
                            IF BillToCustomer."No." <> Rec."Bill-to Customer No." THEN
                                ERROR(BillToCustomerValuesDontMatchErr);
                            EXIT;
                        END;

                        IF NOT BillToCustomer.GET(Rec."Bill-to Customer No.") THEN
                            ERROR(CouldNotFindBillToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(BillToCustomer);

                        Rec."Bill-to Customer Id" := BillToCustomer.SystemId;
                        RegisterFieldSet(Rec.FIELDNO("Bill-to Customer Id"));
                        RegisterFieldSet(Rec.FIELDNO("Bill-to Customer No."));
                    end;
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    Caption = 'shipToName', Locked = true;

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Name" <> Rec."Ship-to Name" then begin
                            Rec."Ship-to Code" := '';
                            RegisterFieldSet(Rec.FIELDNO("Ship-to Code"));
                            RegisterFieldSet(Rec.FIELDNO("Ship-to Name"));
                        end;
                    end;
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                    ApplicationArea = All;
                    Caption = 'shipToContact', Locked = true;

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Contact" <> Rec."Ship-to Contact" then begin
                            Rec."Ship-to Code" := '';
                            RegisterFieldSet(Rec.FIELDNO("Ship-to Code"));
                            RegisterFieldSet(Rec.FIELDNO("Ship-to Contact"));
                        end;
                    end;
                }
                field(sellingPostalAddress; SellingPostalAddressJSONText)
                {
                    ApplicationArea = All;
                    Caption = 'sellingPostalAddress', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the selling address of the Sales Invoice.';

                    trigger OnValidate()
                    begin
                        SellingPostalAddressSet := TRUE;
                    end;
                }
                field(billingPostalAddress; BillingPostalAddressJSONText)
                {
                    ApplicationArea = All;
                    Caption = 'billingPostalAddress', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the billing address of the Sales Invoice.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        Error(BillingPostalAddressIsReadOnlyErr);
                    end;
                }
                field(shippingPostalAddress; ShippingPostalAddressJSONText)
                {
                    ApplicationArea = All;
                    Caption = 'shippingPostalAddress', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the shipping address of the Sales Invoice.';

                    trigger OnValidate()
                    begin
                        ShippingPostalAddressSet := TRUE;
                    end;
                }
                field(currencyId; Rec."Currency Id")
                {
                    ApplicationArea = All;
                    Caption = 'currencyId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF Rec."Currency Id" = BlankGUID THEN
                            Rec."Currency Code" := ''
                        ELSE BEGIN
                            Currency.SETRANGE(SystemId, Rec."Currency Id");
                            IF NOT Currency.FINDFIRST() THEN
                                ERROR(CurrencyIdDoesNotMatchACurrencyErr);

                            Rec."Currency Code" := Currency.Code;
                        END;

                        RegisterFieldSet(Rec.FIELDNO("Currency Id"));
                        RegisterFieldSet(Rec.FIELDNO("Currency Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    ApplicationArea = All;
                    Caption = 'currencyCode', Locked = true;

                    trigger OnValidate()
                    begin
                        Rec."Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        IF Currency.Code <> '' THEN BEGIN
                            IF Currency.Code <> Rec."Currency Code" THEN
                                ERROR(CurrencyValuesDontMatchErr);
                            EXIT;
                        END;

                        IF Rec."Currency Code" = '' THEN
                            Rec."Currency Id" := BlankGUID
                        ELSE BEGIN
                            IF NOT Currency.GET(Rec."Currency Code") THEN
                                ERROR(CurrencyCodeDoesNotMatchACurrencyErr);

                            Rec."Currency Id" := Currency.SystemId;
                        END;

                        RegisterFieldSet(Rec.FIELDNO("Currency Id"));
                        RegisterFieldSet(Rec.FIELDNO("Currency Code"));
                    end;
                }
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'pricesIncludeTax', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Prices Including VAT"));
                    end;
                }
                field(paymentTermsId; Rec."Payment Terms Id")
                {
                    ApplicationArea = All;
                    Caption = 'paymentTermsId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF Rec."Payment Terms Id" = BlankGUID THEN
                            Rec."Payment Terms Code" := ''
                        ELSE BEGIN
                            PaymentTerms.SETRANGE(SystemId, Rec."Payment Terms Id");
                            IF NOT PaymentTerms.FINDFIRST() THEN
                                ERROR(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            Rec."Payment Terms Code" := PaymentTerms.Code;
                        END;

                        RegisterFieldSet(Rec.FIELDNO("Payment Terms Id"));
                        RegisterFieldSet(Rec.FIELDNO("Payment Terms Code"));
                    end;
                }
                field(shipmentMethodId; Rec."Shipment Method Id")
                {
                    ApplicationArea = All;
                    Caption = 'shipmentMethodId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF Rec."Shipment Method Id" = BlankGUID THEN
                            Rec."Shipment Method Code" := ''
                        ELSE BEGIN
                            ShipmentMethod.SETRANGE(SystemId, Rec."Shipment Method Id");
                            IF NOT ShipmentMethod.FINDFIRST() THEN
                                ERROR(ShipmentMethodIdDoesNotMatchAShipmentMethodErr);

                            Rec."Shipment Method Code" := ShipmentMethod.Code;
                        END;

                        RegisterFieldSet(Rec.FIELDNO("Shipment Method Id"));
                        RegisterFieldSet(Rec.FIELDNO("Shipment Method Code"));
                    end;
                }
                field(salesperson; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Caption = 'salesperson', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Salesperson Code"));
                    end;
                }
                field(partialShipping; PartialShipping)
                {
                    ApplicationArea = All;
                    Caption = 'partialShipping', Locked = true;

                    trigger OnValidate()
                    begin
                        ProcessPartialShipping();
                    end;
                }
                field(requestedDeliveryDate; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                    Caption = 'requestedDeliveryDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Requested Delivery Date"));
                    end;
                }
                field(discountAmount; Rec."Invoice Discount Amount")
                {
                    ApplicationArea = All;
                    Caption = 'discountAmount', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Invoice Discount Amount"));
                        InvoiceDiscountAmount := Rec."Invoice Discount Amount";
                        DiscountAmountSet := TRUE;
                    end;
                }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax")
                {
                    ApplicationArea = All;
                    Caption = 'discountAppliedBeforeTax', Locked = true;
                    Editable = false;
                }
                field(totalAmountExcludingTax; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'totalAmountExcludingTax', Locked = true;
                    Editable = false;
                }
                field(totalTaxAmount; Rec."Total Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'totalTaxAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the total tax amount for the sales invoice.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Total Tax Amount"));
                    end;
                }
                field(totalAmountIncludingTax; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'totalAmountIncludingTax', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Amount Including VAT"));
                    end;
                }
                field(fullyShipped; Rec."Completely Shipped")
                {
                    ApplicationArea = All;
                    Caption = 'fullyShipped', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Completely Shipped"));
                    end;
                }
                field(status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'status', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the status of the Sales Invoice (cancelled, paid, on hold, created).';
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                field(phoneNumber; Rec."Sell-to Phone No.")
                {
                    ApplicationArea = All;
                    Caption = 'phoneNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Sell-to Phone No."));
                    end;
                }
                field(email; Rec."Sell-to E-Mail")
                {
                    ApplicationArea = All;
                    Caption = 'email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FIELDNO("Sell-to E-Mail"));
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
        if HasWritePermission then
            GraphMgtSalesOrderBuffer.RedistributeInvoiceDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtSalesOrderBuffer.PropagateOnDelete(Rec);

        EXIT(FALSE);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckSellToCustomerSpecified();
        ProcessSellingPostalAddressOnInsert();
        ProcessShippingPostalAddressOnInsert();

        GraphMgtSalesOrderBuffer.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF xRec.Id <> Rec.Id THEN
            ERROR(CannotChangeIDErr);

        ProcessSellingPostalAddressOnModify();
        ProcessShippingPostalAddressOnModify();

        GraphMgtSalesOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        UpdateDiscount();

        SetCalculatedFields();

        EXIT(FALSE);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    trigger OnOpenPage()
    begin
        CheckPermissions();
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        Currency: Record "Currency";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        GraphMgtSalesOrderBuffer: Codeunit "Graph Mgt - Sales Order Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        SellingPostalAddressJSONText: Text;
        BillingPostalAddressJSONText: Text;
        ShippingPostalAddressJSONText: Text;
        SellingPostalAddressSet: Boolean;
        ShippingPostalAddressSet: Boolean;
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked = true;
        SellToCustomerNotProvidedErr: Label 'A customerNumber or a customerId must be provided.', Locked = true;
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.', Locked = true;
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.', Locked = true;
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.', Locked = true;
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.', Locked = true;
        PartialShipping: Boolean;
        SellToContactIdHasToHaveValueErr: Label 'Sell-to contact Id must have a value set.', Locked = true;
        SalesOrderPermissionsErr: Label 'You do not have permissions to read Sales Orders.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Locked = true;
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Locked = true;
        BillingPostalAddressIsReadOnlyErr: Label 'The "billingPotalAddress" is read-only.', Locked = true;
        CannotFindOrderErr: Label 'The order cannot be found.', Locked = true;
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        BlankGUID: Guid;
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        HasWritePermission: Boolean;

    local procedure SetCalculatedFields()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        SellingPostalAddressJSONText := GraphMgtSalesOrder.SellToCustomerAddressToJSON(Rec);
        BillingPostalAddressJSONText := GraphMgtSalesOrder.BillToCustomerAddressToJSON(Rec);
        ShippingPostalAddressJSONText := GraphMgtSalesOrder.ShipToCustomerAddressToJSON(Rec);
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
        PartialShipping := (Rec."Shipping Advice" = Rec."Shipping Advice"::Partial);
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SellingPostalAddressJSONText);
        CLEAR(BillingPostalAddressJSONText);
        CLEAR(ShippingPostalAddressJSONText);
        CLEAR(DiscountAmountSet);
        CLEAR(InvoiceDiscountAmount);

        PartialShipping := FALSE;
        TempFieldBuffer.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        IF TempFieldBuffer.FINDLAST() THEN
            LastOrderNo := TempFieldBuffer.Order + 1;

        CLEAR(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := DATABASE::"Sales Invoice Entity Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.INSERT();
    end;

    local procedure CheckSellToCustomerSpecified()
    begin
        IF (Rec."Sell-to Customer No." = '') AND
           (Rec."Customer Id" = BlankGUID)
        THEN
            ERROR(SellToCustomerNotProvidedErr);
    end;

    local procedure ProcessSellingPostalAddressOnInsert()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        IF NOT SellingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesOrder.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FIELDNO("Sell-to Address"));
        RegisterFieldSet(Rec.FIELDNO("Sell-to Address 2"));
        RegisterFieldSet(Rec.FIELDNO("Sell-to City"));
        RegisterFieldSet(Rec.FIELDNO("Sell-to Country/Region Code"));
        RegisterFieldSet(Rec.FIELDNO("Sell-to Post Code"));
        RegisterFieldSet(Rec.FIELDNO("Sell-to County"));
    end;

    local procedure ProcessSellingPostalAddressOnModify()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        IF NOT SellingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesOrder.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        IF xRec."Sell-to Address" <> Rec."Sell-to Address" THEN
            RegisterFieldSet(Rec.FIELDNO("Sell-to Address"));

        IF xRec."Sell-to Address 2" <> Rec."Sell-to Address 2" THEN
            RegisterFieldSet(Rec.FIELDNO("Sell-to Address 2"));

        IF xRec."Sell-to City" <> Rec."Sell-to City" THEN
            RegisterFieldSet(Rec.FIELDNO("Sell-to City"));

        IF xRec."Sell-to Country/Region Code" <> Rec."Sell-to Country/Region Code" THEN
            RegisterFieldSet(Rec.FIELDNO("Sell-to Country/Region Code"));

        IF xRec."Sell-to Post Code" <> Rec."Sell-to Post Code" THEN
            RegisterFieldSet(Rec.FIELDNO("Sell-to Post Code"));

        IF xRec."Sell-to County" <> Rec."Sell-to County" THEN
            RegisterFieldSet(Rec.FIELDNO("Sell-to County"));
    end;

    local procedure ProcessShippingPostalAddressOnInsert()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

        Rec."Ship-to Code" := '';
        RegisterFieldSet(Rec.FIELDNO("Ship-to Address"));
        RegisterFieldSet(Rec.FIELDNO("Ship-to Address 2"));
        RegisterFieldSet(Rec.FIELDNO("Ship-to City"));
        RegisterFieldSet(Rec.FIELDNO("Ship-to Country/Region Code"));
        RegisterFieldSet(Rec.FIELDNO("Ship-to Post Code"));
        RegisterFieldSet(Rec.FIELDNO("Ship-to County"));
        RegisterFieldSet(Rec.FIELDNO("Ship-to Code"));
    end;

    local procedure ProcessShippingPostalAddressOnModify()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
        Changed: Boolean;
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

        if xRec."Ship-to Address" <> Rec."Ship-to Address" then begin
            RegisterFieldSet(Rec.FIELDNO("Ship-to Address"));
            Changed := true;
        end;

        if xRec."Ship-to Address 2" <> Rec."Ship-to Address 2" then begin
            RegisterFieldSet(Rec.FIELDNO("Ship-to Address 2"));
            Changed := true;
        end;

        if xRec."Ship-to City" <> Rec."Ship-to City" then begin
            RegisterFieldSet(Rec.FIELDNO("Ship-to City"));
            Changed := true;
        end;

        if xRec."Ship-to Country/Region Code" <> Rec."Ship-to Country/Region Code" then begin
            RegisterFieldSet(Rec.FIELDNO("Ship-to Country/Region Code"));
            Changed := true;
        end;

        if xRec."Ship-to Post Code" <> Rec."Ship-to Post Code" then begin
            RegisterFieldSet(Rec.FIELDNO("Ship-to Post Code"));
            Changed := true;
        end;

        if xRec."Ship-to County" <> Rec."Ship-to County" then begin
            RegisterFieldSet(Rec.FIELDNO("Ship-to County"));
            Changed := true;
        end;

        if Changed then begin
            Rec."Ship-to Code" := '';
            RegisterFieldSet(Rec.FIELDNO("Ship-to Code"));
        end;
    end;

    local procedure ProcessPartialShipping()
    begin
        IF PartialShipping THEN
            Rec."Shipping Advice" := Rec."Shipping Advice"::Partial
        ELSE
            Rec."Shipping Advice" := Rec."Shipping Advice"::Complete;

        RegisterFieldSet(Rec.FIELDNO("Shipping Advice"));
    end;

    local procedure UpdateSellToCustomerFromSellToGraphContactId(var Customer: Record Customer)
    var
        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
        UpdateCustomer: Boolean;
    begin
        UpdateCustomer := Rec."Sell-to Customer No." = '';
        IF NOT UpdateCustomer THEN BEGIN
            TempFieldBuffer.RESET();
            TempFieldBuffer.SETRANGE("Field ID", Rec.FIELDNO("Customer Id"));
            UpdateCustomer := NOT TempFieldBuffer.FINDFIRST();
            TempFieldBuffer.RESET();
        END;

        IF UpdateCustomer THEN BEGIN
            Rec.VALIDATE("Customer Id", Customer.SystemId);
            Rec.VALIDATE("Sell-to Customer No.", Customer."No.");
            RegisterFieldSet(Rec.FIELDNO("Customer Id"));
            RegisterFieldSet(Rec.FIELDNO("Sell-to Customer No."));
        END;

        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(Customer);
    end;

    local procedure CheckPermissions()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        IF NOT SalesHeader.READPERMISSION() THEN
            ERROR(SalesOrderPermissionsErr);

        HasWritePermission := SalesHeader.WRITEPERMISSION();
    end;

    local procedure UpdateDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        IF NOT DiscountAmountSet THEN BEGIN
            GraphMgtSalesOrderBuffer.RedistributeInvoiceDiscounts(Rec);
            EXIT;
        END;

        SalesHeader.GET(SalesHeader."Document Type"::Order, Rec."No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    var
        GraphMgtSalesOrderBuffer: Codeunit "Graph Mgt - Sales Order Buffer";
    begin
        IF NOT DocumentDateSet THEN
            EXIT;

        TempFieldBuffer.RESET();
        TempFieldBuffer.DELETEALL();

        IF DocumentDateSet THEN BEGIN
            Rec."Document Date" := DocumentDateVar;
            RegisterFieldSet(Rec.FIELDNO("Document Date"));
        END;

        GraphMgtSalesOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.FIND();
    end;

    local procedure GetOrder(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.SetRange(SystemId, Rec.Id);
        IF NOT SalesHeader.FindFirst() THEN
            ERROR(CannotFindOrderErr);
    end;

    local procedure PostWithShipAndInvoice(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DummyO365SalesDocument: Record "O365 Sales Document";
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        O365SendResendInvoice: Codeunit "O365 Send + Resend Invoice";
        OrderNo: Code[20];
        OrderNoSeries: Code[20];
    begin
        O365SendResendInvoice.CheckDocumentIfNoItemsExists(SalesHeader, FALSE, DummyO365SalesDocument);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        OrderNo := SalesHeader."No.";
        OrderNoSeries := SalesHeader."No. Series";
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.SendToPosting(CODEUNIT::"Sales-Post");
        SalesInvoiceHeader.SetCurrentKey("Order No.");
        SalesInvoiceHeader.SetRange("Pre-Assigned No. Series", '');
        SalesInvoiceHeader.SetRange("Order No. Series", OrderNoSeries);
        SalesInvoiceHeader.SetRange("Order No.", OrderNo);
        SalesInvoiceHeader.FindFirst();
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; PageId: Integer; DocumentId: Guid)
    var
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(PageId);
        ActionContext.AddEntityKey(Rec.FIELDNO(Id), DocumentId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;
}




















