<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>Opp_Scoring</application>
        <default>false</default>
        <visible>true</visible>
    </applicationVisibilities>
    <classAccesses>
        <apexClass>OppScoring</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>OppScoringBatchInitialize</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>OppScoringInitialize</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>OppScoringRulesController</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>OppScoringTests</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Active__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Campaign__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Field_Label__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Field_Name__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Operator__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Score_Change__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OppScoringRule__c.Value__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Opp_Score__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <layoutAssignments>
        <layout>OppScoringRule__c-Opp Scoring Rule Layout</layout>
    </layoutAssignments>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>OppScoringRule__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <pageAccesses>
        <apexPage>OppScoringDetail</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>OppScoringRulesEdit</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>OppScoringSetup</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <tabVisibilities>
        <tab>OppScoringRule__c</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
    <userLicense>Salesforce</userLicense>
</Profile>
