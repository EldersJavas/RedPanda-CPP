#include "autolinkmanager.h"
#include "settings.h"

#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include "systemconsts.h"

AutolinkManager* pAutolinkManager;

AutolinkManager::AutolinkManager()
{

}

PAutolink AutolinkManager::getLink(const QString &header) const
{
    return mLinks.value(header,PAutolink());
}

void AutolinkManager::load()
{
    QDir dir(pSettings->dirs().config());
    QString filename=dir.filePath(DEV_AUTOLINK_FILE);
    QFile file(filename);
    if (!file.exists()) {
        QFile preFile(":/config/autolink.json");
        if (!preFile.open(QFile::ReadOnly)) {
            throw FileError(QObject::tr("Can't open file '%1' for read.")
                            .arg(":/config/autolink.json"));
        }
        QByteArray content=preFile.readAll();
        if (!file.open(QFile::WriteOnly|QFile::Truncate)) {
            throw FileError(QObject::tr("Can't open file '%1' for write.")
                            .arg(filename));
        }
        file.write(content);
        file.close();
        preFile.close();
    }
    if (file.open(QFile::ReadOnly)) {
        QByteArray content = file.readAll();
        QJsonDocument doc(QJsonDocument::fromJson(content));
        fromJson(doc.array());
        file.close();
    } else {
        throw FileError(QObject::tr("Can't open file '%1' for read.")
                        .arg(filename));
    }
}

void AutolinkManager::save()
{
    QDir dir(pSettings->dirs().config());
    QString filename=dir.filePath(DEV_AUTOLINK_FILE);
    QFile file(filename);
    if (file.open(QFile::WriteOnly|QFile::Truncate)) {
        QJsonDocument doc(toJson());
        file.write(doc.toJson(QJsonDocument::Indented));
        file.close();
    } else {
        throw FileError(QObject::tr("Can't open file '%1' for write.")
                        .arg(filename));
    }
}

void AutolinkManager::setLink(const QString &header, const QString &linkOption)
{
    PAutolink link = mLinks.value(header,PAutolink());
    if (link) {
        link->linkOption = linkOption;
    } else {
        link = std::make_shared<Autolink>();
        link->header = header;
        link->linkOption = linkOption;
        mLinks.insert(header,link);
    }
}

const QMap<QString, PAutolink> &AutolinkManager::links() const
{
    return mLinks;
}

void AutolinkManager::clear()
{
    mLinks.clear();
}

QJsonArray AutolinkManager::toJson()
{
    QJsonArray result;
    foreach (const QString& header, mLinks.keys()){
        QJsonObject autolink;
        autolink["header"]=header;
        autolink["links"]=mLinks[header]->linkOption;
        result.append(autolink);
    }
    return result;
}

void AutolinkManager::fromJson(QJsonArray json)
{
    clear();
    for (int i=0;i<json.size();i++) {
        QJsonObject obj = json[i].toObject();
        setLink(obj["header"].toString(),obj["links"].toString());
    }
}
