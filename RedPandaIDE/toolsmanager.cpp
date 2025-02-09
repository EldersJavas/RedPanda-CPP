#include "toolsmanager.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMessageBox>
#include "settings.h"
#include "systemconsts.h"

ToolsManager::ToolsManager(QObject *parent) : QObject(parent)
{

}

void ToolsManager::load()
{
    //if config file not exists, copy it from data
    QString filename = includeTrailingPathDelimiter(pSettings->dirs().config()) + DEV_TOOLS_FILE;
    if (!fileExists(filename))
        return;
    //read config file
    QFile file(filename);
    if (!file.open(QFile::ReadOnly)) {
        QMessageBox::critical(nullptr,
                              tr("Read tools config failed"),
                              tr("Can't open tools config file '%1' for read.")
                              .arg(filename));
        return;
    }

    QByteArray json = file.readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(json,&error);
    if (error.error != QJsonParseError::NoError) {
        QMessageBox::critical(nullptr,
                              tr("Read tools config failed"),
                              tr("Read tools config file '%1' failed:%2")
                              .arg(filename)
                              .arg(error.errorString()));
        return;
    }
    mTools.clear();
    QJsonArray array = doc.array();
    foreach (const QJsonValue& value,array) {
        QJsonObject object = value.toObject();
        PToolItem item = std::make_shared<ToolItem>();
        item->title = object["title"].toString();
        if (item->title.isEmpty())
            continue;
        item->program = object["program"].toString();
        item->workingDirectory = object["workingDirectory"].toString();
        item->parameters = object["parameters"].toString();
        item->pauseAfterExit = object["pauseAfterExit"].toBool();
        mTools.append(item);
    }
}

void ToolsManager::save()
{
    QString filename = includeTrailingPathDelimiter(pSettings->dirs().config()) + DEV_TOOLS_FILE;
    QFile file(filename);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)) {
        QMessageBox::critical(nullptr,
                              tr("Save tools config failed"),
                              tr("Can't open tools config file '%1' for write.")
                              .arg(filename));
        return;
    }
    QJsonArray array;
    foreach (const PToolItem& tool,mTools) {
        QJsonObject object;
        object["title"]=tool->title;
        object["program"]=tool->program;
        object["workingDirectory"] = tool->workingDirectory;
        object["parameters"]=tool->parameters;
        object["pauseAfterExit"]=tool->pauseAfterExit;
        array.append(object);
    }
    QJsonDocument doc;
    doc.setArray(array);
    if (file.write(doc.toJson())<0) {
        QMessageBox::critical(nullptr,
                              tr("Save tools config failed"),
                              tr("Write to tools config file '%1' failed.")
                              .arg(filename));
        return;
    }

}

const QList<PToolItem> &ToolsManager::tools() const
{
    return mTools;
}

PToolItem ToolsManager::findTool(const QString &title)
{
    for (int i=0;i<mTools.count();i++) {
        PToolItem item = mTools[i];
        if (title == item->title) {
            return item;
        }
    }
    return PToolItem();
}

void ToolsManager::setTools(const QList<PToolItem> &newTools)
{
    mTools = newTools;
}
