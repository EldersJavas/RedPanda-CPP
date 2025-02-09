#include "Search.h"

SynSearch::SynSearch(QObject *parent):SynSearchBase(parent)
{

}

int SynSearch::length(int aIndex)
{
    if (aIndex<0 || aIndex >= mResults.length())
        return 0;
    return pattern().length();
}

int SynSearch::result(int aIndex)
{
    if (aIndex<0 || aIndex >= mResults.length())
        return -1;
    return mResults[aIndex];
}

int SynSearch::resultCount()
{
    return mResults.count();
}

int SynSearch::findAll(const QString &text)
{
    mResults.clear();
    if (pattern().isEmpty())
        return 0;
    int start=0;
    int next=-1;
    while (true) {
        if (options().testFlag(ssoMatchCase)) {
            next = text.indexOf(pattern(),start,Qt::CaseSensitive);
        } else {
            next = text.indexOf(pattern(),start,Qt::CaseInsensitive);
        }
        if (next<0) {
            break;
        }
        start = next + pattern().length();
        if (options().testFlag(ssoWholeWord)) {
            if (((next<=0) || isDelimitChar(text[next-1]))
                    &&
                    ( (start>=text.length()) || isDelimitChar(text[start]) )
                 ) {
                mResults.append(next);
            }
        } else {
            mResults.append(next);
        }

    }
    return mResults.size();
}

QString SynSearch::replace(const QString &, const QString &aReplacement)
{
    return aReplacement;
}

bool SynSearch::isDelimitChar(QChar ch)
{
    return !(ch == '_' || ch.isLetterOrNumber());
}
