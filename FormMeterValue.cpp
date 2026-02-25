                                                                                                        //---------------------------------------------------------------------------

#include <fmx.h>
#pragma hdrstop

#include "FormMeterValue.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.fmx"
TFormMeterValueSettings *FormMeterValueSettings;
//---------------------------------------------------------------------------
__fastcall TFormMeterValueSettings::TFormMeterValueSettings(TComponent* Owner)
    : TForm(Owner)
{
}

void TFormMeterValueSettings::UpdateLayoutCommonSettings()
{
    EditName->Text = MeterValue->Name;

    EditValueType->Text = MeterValue->Type;

    EditShrtName->Text = MeterValue->ShrtName;
    EditDescription->Text = MeterValue->Description;
    EditHash->Text =  IntToStr(MeterValue->Hash);


    CheckBoxIsToSave->Tag = 1;
    CheckBoxIsToSave->IsChecked = MeterValue->IsToSave;
    CheckBoxIsToSave->Tag = 0;
}

void TFormMeterValueSettings::UpdateLayoutValues()
{
    LabelValueName->Text = MeterValue->GetStrFullName();
    EditValueFull->Text = MeterValue->GetStrValue();

    EditValue->Text = FloatToStr(MeterValue->GetDoubleValueDim());
    EditMax->Text = MeterValue->GetStrNum(MeterValue->MaxValue);
    EditMin->Text = MeterValue->GetStrNum(MeterValue->MinValue);
    EditValueDim  ->Text = MeterValue->GetDimName();
}

void TFormMeterValueSettings::RefreshLayoutValues()
{

    MeterValue->Type = EditValueType->Text;
    MeterValue->Name = EditName->Text;
    MeterValue->ShrtName = EditShrtName->Text;
    MeterValue->Description=EditDescription->Text;

    MeterValue->SetValue(EditValue->Text);
    MeterValue->MinValue  =  MeterValue->GetDoubleNum(EditMin->Text);
    MeterValue->MaxValue = MeterValue->GetDoubleNum(EditMax->Text);
    MeterValue->Hash = StrToInt(EditHash->Text);

    MeterValue->SaveToFile(0);
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::FormShow(TObject *Sender)
{
   if (MeterValue!=NULL) {
      UpdateLayoutCommonSettings();
      UpdateLayoutValues();
      UpdateStringGridDimensions();
      UpdateStringGridCoefsData();
      UpdateStringGridCoefs();
      UpdateLayoutCoefs();
      UpdateLayoutValuesList();
   }
}
//-

void TFormMeterValueSettings::UpdateStringGridDimensions()
{
    StringGridDimensions->BeginUpdate();

    StringGridDimensions->RowCount = 0;



    if (!MeterValue->Dimensions.empty()) {

        StringGridDimensions->RowCount = MeterValue->Dimensions.size();

        for (int i = 0; i < MeterValue->Dimensions.size(); i++) {
            StringGridDimensions->Cells[0][i] = i+1;
            StringGridDimensions->Cells[1][i] = MeterValue->Dimensions[i].Name;
            StringGridDimensions->Cells[2][i] = MeterValue->Dimensions[i].Rate;
            StringGridDimensions->Cells[3][i] =
                MeterValue->Dimensions[i].Devider;
            StringGridDimensions->Cells[4][i] =
                BoolToStr(MeterValue->Dimensions[i].Factor);
            StringGridDimensions->Cells[5][i] =
                BoolToStr(MeterValue->Dimensions[i].Recip);
            StringGridDimensions->Cells[6][i] = MeterValue->Dimensions[i].Hash;
        }
    }

     StringGridDimensions->Row = MeterValue->CurrentDimIndex;

     StringGridDimensions->EndUpdate();
}

void TFormMeterValueSettings::UpdateStringGridCoefsData() {
    tCoef coef;
    double dbl;
    int  index = -1;
     StringGridCoefsData->Tag = 1;
    StringGridCoefsData->BeginUpdate();

    StringColumnEtalon->Header =  "Эталон, " +  MeterValue->GetDimName();

    StringColumnValue ->Header =  "Исх. значение, " +  MeterValue->GetDimName();

    StringGridCoefsData->RowCount = 0;

    if (!MeterValue->Coefs.empty()) {
        StringGridCoefsData->RowCount = MeterValue->Coefs.size();

        for (int i = 0; i < MeterValue->Coefs.size(); i++) {
            coef = MeterValue->Coefs[i];

            StringGridCoefsData->Cells[0][i] =
                (coef.InUse == true) ? "True" : "False";
            StringGridCoefsData->Cells[1][i] = coef.Name;

            StringGridCoefsData->Cells[2][i] =
                MeterValue->GetStrNum(coef.Value);

            StringGridCoefsData->Cells[3][i] =
            MeterValue->GetStrNum(coef.Arg);

            StringGridCoefsData->Cells[4][i] =
                RelativeErrorStr(coef.Value, coef.Arg);

            dbl = AbsoluteError(coef.Value, coef.Arg);
            StringGridCoefsData->Cells[5][i] =
                 MeterValue->GetStrNum(dbl);

            StringGridCoefsData->Cells[6][i] = "";
            StringGridCoefsData->Cells[7][i] = coef.Hash;

            if (CoefHash == coef.Hash) {
                 index = i;
            }

        }
    }


    StringGridCoefsData->EndUpdate();

    StringGridCoefsData->Tag = 1;
    StringGridCoefsData->Row = index;



}

void TFormMeterValueSettings::UpdateStringGridCoefs()
{
    StringGridCoefs->BeginUpdate();

    if (!MeterValue->Coefs.empty()) {

        StringGridCoefs->RowCount = MeterValue->Coefs.size();

        for (int i = 0; i < MeterValue->Coefs.size(); i++) {

            StringGridCoefs->Cells[0][i] =
                MeterValue->Coefs[i].InUse;
            StringGridCoefs->Cells[1][i] = MeterValue->Coefs[i].Name;

             StringGridCoefs->Cells[2][i] =
                     MeterValue->GetStrNum(MeterValue->Coefs[i].Q1);
             StringGridCoefs->Cells[3][i] =
                     MeterValue->GetStrNum(MeterValue->Coefs[i].Q2);

             StringGridCoefs->Cells[4][i] =
                    FloatToStr(MeterValue->Coefs[i].K);
             StringGridCoefs->Cells[5][i] =
               FloatToStr(MeterValue->Coefs[i].b);

             StringGridCoefs->Cells[6][i] = MeterValue->Coefs[i].Hash;
        }
    }

      StringGridCoefs->EndUpdate();
}

void __fastcall TFormMeterValueSettings::AddRowButtonClick(TObject* Sender)
{
    CoefHash = MeterValue->SetCoef(0, 0);
    MeterValue->CalcCoefs();
    UpdateStringGridCoefsData();
    UpdateStringGridCoefs();
}
//---------------------------------------------------------------------------


void __fastcall TFormMeterValueSettings::StringGridCoefsDataEditingDone(TObject *Sender,
       const int ACol, const int ARow)
{

   int hash;
   double dbl;
   tCoef* coef;
   int i;

   CoefHash = GetCellIntValueByColumnName(StringGridCoefsData, "Hash", ARow);

   //i = MeterValue->GetCoefIndex(hash);
   //coef = &MeterValue->Coefs[i];

   coef = &MeterValue->Coefs[ARow];

   UnicodeString Cell = StringGridCoefsData->Cells[ACol][ARow];

   if (ACol == 0) {
       coef->InUse =    (Cell=="True")?true:false;
   }

   else if (ACol == 1)
    {
       coef->Name =  Cell;
    }

   else if (ACol == 2)
    {
        coef->Value = MeterValue->GetDoubleNum(Cell);
   }
   else if (ACol == 3)
   {
        coef->Arg = MeterValue->GetDoubleNum(Cell);
   }
   else if (ACol == 4)
   {

     if (TryStrToDouble_(Cell, dbl)) {

       coef->Value = coef->Arg / (1 - dbl / 100);
     }
   }

   else if (ACol == 5)
   {
       if (TryStrToDouble_(Cell, dbl)) {

          dbl =  MeterValue->GetDoubleNum(dbl);
           coef->Value = coef->Arg + dbl;

       }
   }

   else if (ACol == 7)
   {

     if (TryStrToInt_(Cell, hash)) {

       coef->Hash = hash;
     }
      }

      MeterValue->CalcCoefs();

      UpdateStringGridCoefsData();
      UpdateStringGridCoefs();

      StringGridCoefsData->Tag = 2;
}
//---------------------------------------------------------------------------



void __fastcall TFormMeterValueSettings::SaveConfigButtonClick(TObject *Sender)
{
     TMeterValue::SaveToFile(0);
}
//---------------------------------------------------------------------------



void __fastcall TFormMeterValueSettings::DeleteRowButtonClick(TObject *Sender)
{
    if (StringGridCoefsData->Row != -1) {
        MeterValue->Coefs.erase(
            MeterValue->Coefs.begin() + StringGridCoefsData->Row);
    }

  UpdateStringGridCoefsData();
  MeterValue->CalcCoefs();
  UpdateStringGridCoefs();

}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::RefreshConfigButtonClick(TObject *Sender)

{
    if (StringGridCoefsData->Tag == 1) {
        MeterValue->SortCoefs(true);
        StringGridCoefsData->Tag = 0;
    } else
    {
        MeterValue->SortCoefs(false);
        StringGridCoefsData->Tag = 1;
    }

    UpdateStringGridCoefsData();
   // MeterValue->CalcCoefs();
    UpdateStringGridCoefs();
}
//---------------------------------------------------------------------------



void __fastcall TFormMeterValueSettings::LoadConfigButtonClick(TObject *Sender)
{
    TMeterValue::LoadFromFile();
     UpdateStringGridCoefsData();
      MeterValue->CalcCoefs();
      UpdateStringGridCoefs();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::StringGridDimensionsSelChanged(TObject *Sender)

{
    if (StringGridDimensions->Row != -1) {

     MeterValue-> SetDim(StringGridDimensions->Row);

    }
}
//---------------------------------------------------------------------------


void __fastcall TFormMeterValueSettings::ButtonCoefsLoadClick(TObject *Sender)
{
      TMeterValue::LoadFromFile();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::TabControlMeterValueSettingsChange(TObject *Sender)
{

     if (TabControlMeterValueSettings->TabIndex == 0) {
         UpdateLayoutCommonSettings();
         UpdateLayoutValues();
         UpdateLayoutCoefs();
     } else if (TabControlMeterValueSettings->TabIndex == 1) {
         UpdateStringGridCoefsData();
         UpdateStringGridCoefs();
     } else if (TabControlMeterValueSettings->TabIndex == 2) {
         UpdateStringGridDimensions();
     }
}
//---------------------------------------------------------------------------




void __fastcall TFormMeterValueSettings::CheckBoxIsToSaveChange(TObject *Sender)
{
    if (CheckBoxIsToSave->Tag == 0) {
     MeterValue->SetToSave(CheckBoxIsToSave->IsChecked);
    } else
    {
     CheckBoxIsToSave->Tag = 0;
    }
}
//---------------------------------------------------------------------------







void __fastcall TFormMeterValueSettings::EditNameExit(TObject *Sender)
{
     RefreshLayoutValues();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditShrtNameExit(TObject *Sender)
{
     RefreshLayoutValues();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditDescriptionExit(TObject *Sender)
{
     RefreshLayoutValues();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditHashExit(TObject *Sender)
{
     RefreshLayoutValues();
}
//---------------------------------------------------------------------------







void __fastcall TFormMeterValueSettings::EditValueExit(TObject *Sender)
{
        RefreshLayoutValues();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditValueDimExit(TObject *Sender)
{
        RefreshLayoutValues();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditMinExit(TObject *Sender)
{
        RefreshLayoutValues();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditMaxExit(TObject *Sender)
{
      RefreshLayoutValues();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::Z(TObject *Sender)
{
     double dbl = StrToDouble_(EditTestValueDim->Text);
     MeterValue->SetDimValue(dbl);
     UpdateLayoutTest();
     EditTestValueRaw->Text = "";
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditTestValueRawExit(TObject *Sender)
{
      double dbl = StrToDouble_(EditTestValueRaw->Text);
      MeterValue->SetRawValue(dbl);
      UpdateLayoutTest();
      EditTestValueDim->Text = "";
}
//---------------------------------------------------------------------------

void TFormMeterValueSettings::UpdateLayoutTest()
{
    LabelValueRaw->Text =  "Исходное значение (" +   MeterValue->GetRawValueFullName() + ")";
    LabelValueDim->Text = "Заданное значение (" +   MeterValue->GetStrFullName() + ")";

    LabelTestValue->Text =
        MeterValue->GetStringValue() + " " + MeterValue->GetDimName(0);

    LabelTestValueWoCorrection->Text =
        MeterValue->GetStringNum(MeterValue->ValueWoCorrection) + " " +
        MeterValue->GetDimName(0);

    LabelTestValueDim->Text =
        MeterValue->GetStrValue() + " " + MeterValue->GetDimName();


}

void __fastcall TFormMeterValueSettings::StringGridCoefsDataSelChanged(
    TObject* Sender)
{


    if (StringGridCoefsData->Tag == 0) {
        int ARow = StringGridCoefsData->Row;
        CoefHash =
            GetCellIntValueByColumnName(StringGridCoefsData, "Hash", ARow);
    } else if (StringGridCoefsData->Tag == 2) {
         StringGridCoefsData->Tag = 1;
         StringGridCoefsData->Row = MeterValue->GetCoefIndex(CoefHash);

    } else

    {
       StringGridCoefsData->Tag = 0;
    }
}
//---------------------------------------------------------------------------




void __fastcall TFormMeterValueSettings::TabItem4Click(TObject *Sender)
{
             UpdateLayoutTest();
}
//---------------------------------------------------------------------------

void TFormMeterValueSettings::UpdateLayoutValuesList()
{
    int index = -1;
    int col =0;
    int size = TMeterValue::MeterValues.size();
    StringGridValuesList->BeginUpdate();
    StringGridValuesList->Tag = 1 ;
    StringGridValuesList->RowCount = 0;
    TFlowMeter* FlowMeter;

    if (!TMeterValue::MeterValues.empty()) {
        StringGridValuesList->RowCount = size;

        for (int i = 0; i < size; i++) {
            col =0;
            StringGridValuesList->Cells[col++][i] = IntToStr(i);

            //FlowMeter = TFlowMeter::GetMeter(TMeterValue::MeterValues[i]->HashOwner);

            if (FlowMeter != nullptr) {
          //      StringGridValuesList->Cells[col++][i] =
          //         TMeterValue::MeterValues[i]->NameOwner;
            } else {
         //       StringGridValuesList->Cells[col++][i] = "-";
            }


                StringGridValuesList->Cells[col++][i] =
                   TMeterValue::MeterValues[i]->NameOwner;

            if (TMeterValue::MeterValues[i] != nullptr) {
                StringGridValuesList->Cells[col++][i] =
                    TMeterValue::MeterValues[i]->GetStrFullName();

                StringGridValuesList->Cells[col++][i] =
                    TMeterValue::MeterValues[i]->GetStrValue();

                StringGridValuesList->Cells[col++][i] =
                    IntToStr(TMeterValue::MeterValues[i]->Hash);

                if (TMeterValue::MeterValues[i]->ValueRate != nullptr) {
                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueRate->GetStrFullName();

                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]->ValueRate->GetStrValue();

                    StringGridValuesList->Cells[col++][i] =
                        IntToStr(TMeterValue::MeterValues[i]->ValueRate->Hash);
                }

                if (TMeterValue::MeterValues[i]->ValueBaseMultiplier != nullptr)
                {
                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueBaseMultiplier->GetStrFullName();

                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueBaseMultiplier->GetStrValue();

                    StringGridValuesList->Cells[col++][i] = IntToStr(
                        TMeterValue::MeterValues[i]->ValueBaseMultiplier->Hash);
                }

                if (TMeterValue::MeterValues[i]->ValueBaseDevider != nullptr) {
                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueBaseDevider->GetStrFullName();

                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueBaseDevider->GetStrValue();

                    StringGridValuesList->Cells[col++][i] = IntToStr(
                        TMeterValue::MeterValues[i]->ValueBaseDevider->Hash);
                }

                if (TMeterValue::MeterValues[i]->ValueCorrection != nullptr) {
                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueCorrection->GetStrFullName();

                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueCorrection->GetStrValue();

                    StringGridValuesList->Cells[col++][i] = IntToStr(
                        TMeterValue::MeterValues[i]->ValueCorrection->Hash);
                }

                if (TMeterValue::MeterValues[i]->ValueEtalon != nullptr) {
                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]
                            ->ValueEtalon->GetStrFullName();

                    StringGridValuesList->Cells[col++][i] =
                        TMeterValue::MeterValues[i]->ValueEtalon->GetStrValue();

                    StringGridValuesList->Cells[col++][i] = IntToStr(
                        TMeterValue::MeterValues[i]->ValueEtalon->Hash);
                }
            }

                 if (TMeterValue::MeterValues[i]->Hash == MeterValue->Hash) {
                   index = i;
                }

        }
    }
          StringGridValuesList->Row = index;
          StringGridValuesList->Tag = 0 ;
      StringGridValuesList->EndUpdate();
}

void __fastcall TFormMeterValueSettings::TabItemListValuesClick(TObject *Sender)
{
    UpdateLayoutValuesList();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::StringGridValuesListSelChanged(TObject *Sender)

{
 if (StringGridValuesList->Tag == 0) {
    if (StringGridValuesList->Row < TMeterValue::MeterValues.size())
    {
        MeterValue = TMeterValue::MeterValues[StringGridValuesList->Row];
    }
 }

    UpdateLayoutValues();
    UpdateStringGridCoefs();
    UpdateStringGridCoefsData();
}
//---------------------------------------------------------------------------

void TFormMeterValueSettings::UpdateLayoutCoefs()
{

    if (MeterValue->ValueRate!=nullptr) {
        EditNameValueRate->Text = MeterValue->ValueRate->GetStrFullName();
        EditValueRate->Text = MeterValue->ValueRate->GetStrValue();
    } else {
        EditNameValueRate->Text = "-";
        EditValueRate->Text = "-";
    }

     if (MeterValue->ValueBaseMultiplier!=nullptr) {
        EditNameValueMultiplier->Text = MeterValue->ValueBaseMultiplier->GetStrFullName();
        EditValueMultiplier->Text = MeterValue->ValueBaseMultiplier->GetStrValue();
    } else {
        EditNameValueMultiplier->Text = "-";
        EditValueMultiplier->Text = "-";
    }

    if (MeterValue->ValueBaseDevider!=nullptr) {
        EditNameValueDevider->Text = MeterValue->ValueBaseDevider->GetStrFullName();
        EditValueDevider->Text = MeterValue->ValueBaseDevider->GetStrValue();
    } else {
        EditNameValueDevider->Text = "-";
        EditValueDevider->Text = "-";
    }

    EditCoefK->Text = FloatToStr(MeterValue->CoefK);
    EditCoefP->Text = FloatToStr(MeterValue->CoefP);

    }


void TFormMeterValueSettings::RefreshLayoutCoefs()
{
    double dbl;
    /*
        MeterValue->ValueRate->GetStrFullName();
        EditNameValueRate->Text =
        EditValueRate->Text = MeterValue->ValueRate->GetStrValue();


     if (MeterValue->ValueBaseMultiplier!=nullptr) {
        EditNameValueMultiplier->Text = MeterValue->ValueBaseMultiplier->GetStrFullName();
        EditValueMultiplier->Text = MeterValue->ValueBaseMultiplier->GetStrValue();
    } else {
        EditNameValueMultiplier->Text = "-";
        EditValueMultiplier->Text = "-";
    }

    if (MeterValue->ValueBaseDevider!=nullptr) {
        EditNameValueDevider->Text = MeterValue->ValueBaseDevider->GetStrFullName();
        EditValueDevider->Text = MeterValue->ValueBaseDevider->GetStrValue();
    } else {
        EditNameValueDevider->Text = "-";
        EditValueDevider->Text = "-";
    }
    */


    if (TryStrToDouble_(EditCoefK->Text, dbl)) {
     MeterValue->CoefK = dbl;
    }

    if (TryStrToDouble_(EditCoefP->Text, dbl)) {
     MeterValue->CoefP = dbl;
    }
}



void __fastcall TFormMeterValueSettings::EditCoefKExit(TObject *Sender)
{
      RefreshLayoutCoefs();
}
//---------------------------------------------------------------------------

void __fastcall TFormMeterValueSettings::EditCoefPExit(TObject *Sender)
{
     RefreshLayoutCoefs();
}
//---------------------------------------------------------------------------











