#ifndef DATABASEBOUNDARY_H_
#define DATABASEBOUNDARY_H_

#include "DatabaseHelper.h"

namespace canadainc {
    class DatabaseHelper;
}

namespace salat {

using namespace canadainc;

class DatabaseBoundary : public QObject
{
	Q_OBJECT

	DatabaseHelper m_sql;

public:
	DatabaseBoundary();
	virtual ~DatabaseBoundary();

    Q_INVOKABLE void fetchRandomBenefit(QObject* caller);
};

}
#endif
