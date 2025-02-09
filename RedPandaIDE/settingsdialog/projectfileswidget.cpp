#include "projectfileswidget.h"
#include "ui_projectfileswidget.h"
#include "../mainwindow.h"
#include "../systemconsts.h"
#include "../platform.h"

ProjectFilesWidget::ProjectFilesWidget(const QString &name, const QString &group, QWidget *parent) :
    SettingsWidget(name,group,parent),
    ui(new Ui::ProjectFilesWidget)
{
    ui->setupUi(this);
}

ProjectFilesWidget::~ProjectFilesWidget()
{
    delete ui;
}

void ProjectFilesWidget::doLoad()
{
    std::shared_ptr<Project> project = pMainWindow->project();
    if (!project)
        return;
    copyUnits();
    ui->treeProject->setModel(project->model());
    ui->treeProject->expandAll();
    ui->grpFileOptions->setEnabled(false);
}

void ProjectFilesWidget::doSave()
{
    for (int i=0;i<mUnits.count();i++) {
        PProjectUnit unitCopy = mUnits[i];
        PProjectUnit unit = pMainWindow->project()->units()[i];
        unit->setPriority(unitCopy->priority());
        unit->setCompile(unitCopy->compile());
        unit->setLink(unitCopy->link());
        unit->setCompileCpp(unitCopy->compileCpp());
        unit->setOverrideBuildCmd(unitCopy->overrideBuildCmd());
        unit->setBuildCmd(unitCopy->buildCmd());
        unit->setEncoding(unitCopy->encoding());
    }
    pMainWindow->project()->sortUnitsByPriority();
    pMainWindow->project()->saveUnits();
    copyUnits();
    ui->treeProject->expandAll();
    ui->treeProject->clicked(ui->treeProject->currentIndex());
}

PProjectUnit ProjectFilesWidget::currentUnit()
{
    QModelIndex index = ui->treeProject->currentIndex();
    if (!index.isValid())
        return PProjectUnit();
    FolderNode* node = static_cast<FolderNode*>(index.internalPointer());
    if (!node)
        return PProjectUnit();
    int i = node->unitIndex;
    if (i>=0) {
        return mUnits[i];
    } else
        return PProjectUnit();
}

void ProjectFilesWidget::copyUnits()
{
    std::shared_ptr<Project> project = pMainWindow->project();
    if (!project)
        return;
    mUnits.clear();
    foreach (const PProjectUnit& unit, project->units()) {
        PProjectUnit unitCopy = std::make_shared<ProjectUnit>(project.get());
        unitCopy->setPriority(unit->priority());
        unitCopy->setCompile(unit->compile());
        unitCopy->setLink(unit->link());
        unitCopy->setCompileCpp(unit->compileCpp());
        unitCopy->setOverrideBuildCmd(unit->overrideBuildCmd());
        unitCopy->setBuildCmd(unit->buildCmd());
        unitCopy->setEncoding(unit->encoding());
        mUnits.append(unitCopy);
    }
}

void ProjectFilesWidget::disableFileOptions()
{
    ui->grpFileOptions->setEnabled(false);
    ui->spinPriority->setValue(0);
    ui->chkCompile->setChecked(false);
    ui->chkLink->setChecked(false);
    ui->chkCompileAsCPP->setChecked(false);
    ui->chkOverrideBuildCommand->setChecked(false);
    ui->txtBuildCommand->setPlainText("");
}

void ProjectFilesWidget::on_treeProject_doubleClicked(const QModelIndex &index)
{
    if (!index.isValid()) {
        disableFileOptions();
        return ;
    }
    FolderNode* node = static_cast<FolderNode*>(index.internalPointer());
    if (!node) {
        disableFileOptions();
        return;
    }
    int i = node->unitIndex;
    if (i>=0) {
        PProjectUnit unit = mUnits[i];
        ui->grpFileOptions->setEnabled(true);
        ui->spinPriority->setValue(unit->priority());
        ui->chkCompile->setChecked(unit->compile());
        ui->chkLink->setChecked(unit->link());
        ui->chkCompileAsCPP->setChecked(unit->compileCpp());
        ui->chkOverrideBuildCommand->setChecked(unit->overrideBuildCmd());
        ui->txtBuildCommand->setPlainText(unit->buildCmd());
        ui->txtBuildCommand->setEnabled(ui->chkOverrideBuildCommand->isChecked());
        ui->cbEncoding->setCurrentText(unit->encoding());
    } else {
        disableFileOptions();
    }
}


void ProjectFilesWidget::on_spinPriority_valueChanged(int)
{
    PProjectUnit unit = currentUnit();
    if(!unit)
        return;
    unit->setPriority(ui->spinPriority->value());
}


void ProjectFilesWidget::on_chkCompile_stateChanged(int)
{
    PProjectUnit unit = currentUnit();
    if(!unit)
        return;
    unit->setCompile(ui->chkCompile->isChecked());
}


void ProjectFilesWidget::on_chkLink_stateChanged(int)
{
    PProjectUnit unit = currentUnit();
    if(!unit)
        return;
    unit->setLink(ui->chkLink->isChecked());
}


void ProjectFilesWidget::on_chkCompileAsCPP_stateChanged(int )
{
    PProjectUnit unit = currentUnit();
    if(!unit)
        return;
    unit->setCompileCpp(ui->chkCompileAsCPP->isChecked());
}


void ProjectFilesWidget::on_chkOverrideBuildCommand_stateChanged(int )
{
    PProjectUnit unit = currentUnit();
    if(!unit)
        return;
    unit->setOverrideBuildCmd(ui->chkOverrideBuildCommand->isChecked());
    ui->txtBuildCommand->setEnabled(ui->chkOverrideBuildCommand->isChecked());
}


void ProjectFilesWidget::on_txtBuildCommand_textChanged()
{
    PProjectUnit unit = currentUnit();
    if(!unit)
        return;
    unit->setBuildCmd(ui->txtBuildCommand->toPlainText());
}


void ProjectFilesWidget::on_cbEncoding_currentTextChanged(const QString &)
{
    QString userData = ui->cbEncoding->currentData().toString();
    if (userData == ENCODING_AUTO_DETECT
            || userData == ENCODING_SYSTEM_DEFAULT
            || userData == ENCODING_UTF8) {
        PProjectUnit unit = currentUnit();
        if(!unit)
            return;
        unit->setEncoding(userData.toLocal8Bit());
        ui->cbEncodingDetail->setVisible(false);
        ui->cbEncodingDetail->clear();
    } else {
        ui->cbEncodingDetail->setVisible(true);
        ui->cbEncodingDetail->clear();
        QList<PCharsetInfo> infos = pCharsetInfoManager->findCharsetsByLanguageName(userData);
        foreach (const PCharsetInfo& info, infos) {
            ui->cbEncodingDetail->addItem(info->name);
        }
    }
}


void ProjectFilesWidget::on_treeProject_clicked(const QModelIndex &index)
{
    on_treeProject_doubleClicked(index);
}

void ProjectFilesWidget::init()
{
    ui->spinPriority->setMinimum(0);
    ui->spinPriority->setMaximum(9999);
    ui->cbEncodingDetail->setVisible(false);
    ui->cbEncoding->clear();
    ui->cbEncoding->addItem(tr("Auto detect"),ENCODING_AUTO_DETECT);
    ui->cbEncoding->addItem(tr("ANSI"),ENCODING_SYSTEM_DEFAULT);
    ui->cbEncoding->addItem(tr("UTF-8"),ENCODING_UTF8);
    foreach (const QString& langName, pCharsetInfoManager->languageNames()) {
        ui->cbEncoding->addItem(langName,langName);
    }
    SettingsWidget::init();
}


void ProjectFilesWidget::on_cbEncodingDetail_currentTextChanged(const QString &)
{
    PProjectUnit unit = currentUnit();
    if(!unit)
        return;
    unit->setEncoding(ui->cbEncodingDetail->currentText().toLocal8Bit());
}

