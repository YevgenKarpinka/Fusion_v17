pageextension 50001 "Item Card Ext." extends "Item Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(Item)
        {
            field("No. 2"; Rec."No. 2")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
        addafter(Warehouse)
        {
            group(groupItemDescription)
            {
                CaptionML = ENU = 'Item Descriptions';
                Editable = EditAllowed;

                field("Manufacturer Code"; Rec."Manufacturer Code")
                {
                    ApplicationArea = All;
                }
                field("Brand Code"; Rec."Brand Code")
                {
                    ApplicationArea = All;
                }
                field("Name RU"; ItemDescription."Name RU")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Name RU 2"; ItemDescription."Name RU 2")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Name ENG"; ItemDescription."Name ENG")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Name ENG 2"; ItemDescription."Name ENG 2")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                group(groupDescription)
                {
                    CaptionML = ENU = 'Description';

                    field("iDescription"; txtDescription)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo(Description), txtDescription);
                        end;
                    }
                }
                group(groupIngredients)
                {
                    CaptionML = ENU = 'Ingredients';

                    field("Ingredients"; txtIngredients)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo(Ingredients), txtIngredients);
                        end;
                    }
                }
                group(groupIndications)
                {
                    CaptionML = ENU = 'Indications';

                    field("Indications"; txtIndications)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo(Indications), txtIndications);
                        end;
                    }
                }
                group(groupDirections)
                {
                    CaptionML = ENU = 'Directions';

                    field("Directions"; txtDirections)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo(Directions), txtDirections);
                        end;
                    }
                }
                group(groupDescriptionRU)
                {
                    CaptionML = ENU = 'Description RU';

                    field("Description RU"; txtDescriptionRU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Description RU"), txtDescriptionRU);
                        end;
                    }
                }
                group(groupIngredientsRU)
                {
                    CaptionML = ENU = 'Ingredients RU';

                    field("Ingredients RU"; txtIngredientsRU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Ingredients RU"), txtIngredientsRU);
                        end;
                    }
                }
                group(groupIndicationsRU)
                {
                    CaptionML = ENU = 'Indications RU';

                    field("Indications RU"; txtIndicationsRU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Indications RU"), txtIndicationsRU);
                        end;
                    }
                }
                group(groupDirectionsRU)
                {
                    CaptionML = ENU = 'Directions RU';

                    field("Directions RU"; txtDirectionsRU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Directions RU"), txtDirectionsRU);
                        end;
                    }
                }
                group(groupWarning)
                {
                    CaptionML = ENU = 'Warning';

                    field("Warning"; txtWarning)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo(Warning), txtWarning);
                        end;
                    }
                }
                group(groupLegalDisclaimer)
                {
                    CaptionML = ENU = 'Legal Disclaimer';
                    field("Legal Disclaimer"; txtLegalDisclaimer)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Legal Disclaimer"), txtLegalDisclaimer);
                        end;
                    }
                }
            }
            group(BulletPointArea)
            {
                CaptionML = ENU = 'Bullet Points';
                Editable = EditAllowed;

                group(groupBulletPoint1)
                {
                    CaptionML = ENU = 'Bullet Point 1';

                    field("BulletPoint1"; txtBulletPoint1)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 1"), txtBulletPoint1);
                        end;
                    }
                }
                group(groupBulletPoint2)
                {
                    CaptionML = ENU = 'Bullet Point 2';

                    field("BulletPoint2"; txtBulletPoint2)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 2"), txtBulletPoint2);
                        end;
                    }
                }
                group(groupBulletPoint3)
                {
                    CaptionML = ENU = 'Bullet Point 3';

                    field("BulletPoint3"; txtBulletPoint3)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 3"), txtBulletPoint3);
                        end;
                    }
                }
                group(groupBulletPoint4)
                {
                    CaptionML = ENU = 'Bullet Point 4';

                    field("BulletPoint4"; txtBulletPoint4)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 4"), txtBulletPoint4);
                        end;
                    }
                }
                field("Bullet Point 5"; ItemDescription."Bullet Point 5")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                group(groupBulletPoint1RU)
                {
                    CaptionML = ENU = 'Bullet Point 1 RU';

                    field("Bullet Point 1 RU"; txtBulletPoint1RU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 1 RU"), txtBulletPoint1RU);
                        end;
                    }
                }
                group(groupBulletPoint2RU)
                {
                    CaptionML = ENU = 'Bullet Point 2 RU';

                    field("Bullet Point 2 RU"; txtBulletPoint2RU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 2 RU"), txtBulletPoint2RU);
                        end;
                    }
                }
                group(groupBulletPoint3RU)
                {
                    CaptionML = ENU = 'Bullet Point 3 RU';

                    field("Bullet Point 3 RU"; txtBulletPoint3RU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 3 RU"), txtBulletPoint3RU);
                        end;
                    }
                }
                group(groupBulletPoint4RU)
                {
                    CaptionML = ENU = 'Bullet Point 4 RU';

                    field("Bullet Point 4 RU"; txtBulletPoint4RU)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Bullet Point 3 RU"), txtBulletPoint4RU);
                        end;
                    }
                }
                field("Bullet Point 5 RU"; ItemDescription."Bullet Point 5 RU")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
            }
            group(SearchArea)
            {
                CaptionML = ENU = 'Searches';
                Editable = EditAllowed;

                group(groupSearchTerms)
                {
                    CaptionML = ENU = 'Search Terms';

                    field("Search Terms"; txtSearchTerms)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Search Terms"), txtSearchTerms);
                        end;
                    }
                }
                group(groupSearchTermsForGoogleOnly)
                {
                    CaptionML = ENU = 'Search Terms For Google Only';

                    field("Search Terms For Google Only"; txtSearchTermsForGoogleOnly)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            if txtSearchTermsForGoogleOnly = '' then exit;
                            if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                            ItemDescription.BlobOnValidate(ItemDescription.FieldNo("Search Terms for Google only"), txtSearchTermsForGoogleOnly);
                        end;
                    }
                }
            }
            group(groupURLArea)
            {
                CaptionML = ENU = 'URLs';
                Editable = EditAllowed;

                field("Main Image URL"; ItemDescription."Main Image URL")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Other Image URL"; ItemDescription."Other Image URL")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Label Image URL"; ItemDescription."Label Image URL")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Label Image URL 2"; ItemDescription."Label Image URL 2")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Baby Care"; Rec."Baby Care")
                {
                    ApplicationArea = All;
                }
                field("Web Item"; Rec."Web Item")
                {
                    ApplicationArea = All;
                }
            }
            group(groupWebArea)
            {
                CaptionML = ENU = 'Web';
                Editable = EditAllowed;

                field("New Item to"; ItemDescription.New)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Sell-out to"; ItemDescription."Sell-out")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(Barcode; ItemDescription.Barcode)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(UnitCountNet; ItemDescription."Unit Count Net")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(UnitCountType; ItemDescription."Unit Count Type")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(FDA_Code; ItemDescription."FDA Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(HTS_Code; ItemDescription."HTS Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(ProductType; ItemDescription."Product Type")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(ItemTypeKeyword; ItemDescription."Item Type Keyword")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(PackageQty; ItemDescription."Package Quantity")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(ServingSize; ItemDescription."Serving Size")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field(ServingsPerContainer; ItemDescription."Servings per container")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
                        ItemDescriptionModify;
                    end;
                }
                field("Warning Qty"; Rec."Warning Qty")
                {
                    ApplicationArea = All;
                }
                field("Web Price"; Rec."Web Price")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addbefore(Dimensions)
        {
            action(ItemFilterGroup)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Item Filter Group', RUS = 'Группы фильтров товара';
                Image = EditFilter;

                trigger OnAction()
                var
                    _ItemFilterGroup: Record "Item Filter Group";
                    itemFilterGroupList: Page "Item Filter Group List";
                begin
                    _ItemFilterGroup.SetRange("Item No.", Rec."No.");
                    // Page.RunModal(Page::"Item Filter Group List", _ItemFilterGroup);
                    itemFilterGroupList.SetInit(true);
                    itemFilterGroupList.SetTableView(_ItemFilterGroup);
                    itemFilterGroupList.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        BlobOnAfterGetRec();
    end;

    local procedure BlobOnAfterGetRec()
    begin
        if (xRec."No." = Rec."No.") then exit;
        ItemDescriptionExist := false;
        EditAllowed := CurrPage.EDITABLE;
        Clear(txtWarning);
        Clear(txtLegalDisclaimer);
        Clear(txtDescription);
        Clear(txtBulletPoint1);
        Clear(txtBulletPoint2);
        Clear(txtBulletPoint3);
        Clear(txtBulletPoint4);
        Clear(txtSearchTerms);
        Clear(txtSearchTermsForGoogleOnly);
        Clear(txtIngredients);
        Clear(txtIndications);
        Clear(txtDirections);
        Clear(txtDescriptionRU);
        Clear(txtBulletPoint1RU);
        Clear(txtBulletPoint2RU);
        Clear(txtBulletPoint3RU);
        Clear(txtBulletPoint4RU);
        Clear(txtIngredientsRU);
        Clear(txtIndicationsRU);
        Clear(txtDirectionsRU);
        if ItemDescription.Get(Rec."No.") then begin
            ItemDescriptionExist := true;
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo(Warning), txtWarning);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Legal Disclaimer"), txtLegalDisclaimer);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo(Description), txtDescription);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 1"), txtBulletPoint1);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 2"), txtBulletPoint2);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 3"), txtBulletPoint3);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 4"), txtBulletPoint4);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Search Terms"), txtSearchTerms);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Search Terms for Google only"), txtSearchTermsForGoogleOnly);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo(Ingredients), txtIngredients);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo(Indications), txtIndications);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo(Directions), txtDirections);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Description RU"), txtDescriptionRU);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 1 RU"), txtBulletPoint1RU);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 2 RU"), txtBulletPoint2RU);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 3 RU"), txtBulletPoint3RU);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Bullet Point 4 RU"), txtBulletPoint4RU);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Ingredients RU"), txtIngredientsRU);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Indications RU"), txtIndicationsRU);
            ItemDescription.BlobOnAfterGetRec(ItemDescription.FieldNo("Directions RU"), txtDirectionsRU);
        end;
    end;

    local procedure ItemDescriptionModify()
    begin
        if not ItemDescriptionExist then ItemDescription.InitItemDescription(Rec."No.");
        ItemDescription.Modify();
    end;

    var
        ItemDescriptionExist: Boolean;
        EditAllowed: Boolean;
        ItemDescription: Record "Item Description";
        txtWarning: Text;
        txtLegalDisclaimer: Text;
        txtDescription: Text;
        txtBulletPoint1: Text;
        txtBulletPoint2: Text;
        txtBulletPoint3: Text;
        txtBulletPoint4: Text;
        txtSearchTerms: Text;
        txtSearchTermsForGoogleOnly: Text;
        txtIngredients: Text;
        txtIndications: Text;
        txtDirections: Text;
        txtDescriptionRU: Text;
        txtBulletPoint1RU: Text;
        txtBulletPoint2RU: Text;
        txtBulletPoint3RU: Text;
        txtBulletPoint4RU: Text;
        txtIngredientsRU: Text;
        txtIndicationsRU: Text;
        txtDirectionsRU: Text;
}
