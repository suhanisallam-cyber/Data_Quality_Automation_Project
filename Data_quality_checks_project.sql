create table candidates (
    candidate_id int primary key,
    name varchar(100),
    email varchar(150),
    phone varchar(20),
    city varchar(100),
    created_at date
);

create table employers (
    employer_id int primary key,
    company_name varchar(150),
    email varchar(150),
    phone varchar(20),
    city varchar(100)
);

create table postings (
    posting_id int primary key,
    employer_id int,
    job_title varchar(150),
    location varchar(100),
    posted_date date,
    status varchar(30)
);

create table applications (
    application_id int primary key,
    candidate_id int,
    posting_id int,
    application_date date,
    status varchar(30)
);


select*from candidates;
select*from employers;
select*from postings;
select*from applications;

-- data count
select 'candidates' as table_name, COUNT(*) AS total_rows from candidates
union all
select 'employers', COUNT(*) from employers
union all 
select 'postings', COUNT(*) from postings
union all 
select 'applications', COUNT(*) from applications;

-- data profiling
-- candidates table data profiling
select 
    count(*) as total_records, 
    count(*) filter (where name is null) as missing_name, 
    count(*) filter (where email is null) as missing_email, 
    count(*) filter (where phone is null) as missing_phone, 
    count(*) filter (where city is null) as missing_city 
from candidates;

-- employers table data profiling
select 
    count(*) as total_records, 
    count(*) filter (where company_name is null) as missing_company_name, 
    count(*) filter (where email is null) as missing_email, 
    count(*) filter (where phone is null) as missing_phone, 
    count(*) filter (where city is null) as missing_city 
from employers;

-- postings table data profiling
select 
    count(*) as total_records, 
    count(*) filter (where employer_id is null) as missing_employer_id, 
    count(*) filter (where job_title is null) as missing_job_title, 
    count(*) filter (where location is null) as missing_location, 
    count(*) filter (where posted_date is null) as missing_posted_date, 
    count(*) filter (where status is null) as missing_status 
from postings;

-- applications table data profiling
select
    count(*) as total_records,
    count(*) filter (where candidate_id is null) as missing_candidate_id,
    count(*) filter (where posting_id is null) as missing_posting_id,
    count(*) filter (where application_date is null) as missing_application_date,
    count(*) filter (where status is null) as missing_status
from applications;

-- missing email
select
    candidate_id,
    name,
    email
from candidates
where email is null;

-- missing city
select
    candidate_id,
    name,
    city
from candidates
where city is null;

select *
from candidates;

-- phone number in the email column
select
    candidate_id,
    name,
    email
from candidates
where email ~ '^[0-9]+$';

-- invalid email formate
select
    candidate_id,
    name,
    email
from candidates
where email is not null
  AND email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

-- duplicate employers
select
    company_name,
    count(*) as duplicate_count
from employers
group by company_name
having count(*) > 1;

-- duplicate employers by email
select
    email,
    count(*) as duplicate_count
from employers
where email is not null
group by email
having count(*) > 1;

-- employers missing phone 
select
    employer_id,
    company_name,
    phone
from employers
where phone is null
   or trim(phone) = '';

-- orphane applications
select
    a.application_id,
    a.candidate_id,
    a.posting_id
from applications a
left join postings p
    on a.posting_id = p.posting_id
where p.posting_id is null;

-- verifying applications,candidates and posting id
select
    application_id,
    candidate_id,
    posting_id
from applications
order by application_id;

-- orphane applications
select
    a.application_id,
    a.posting_id,
    p.posting_id as matching_posting
from applications a
left join postings p
    on a.posting_id = p.posting_id
where a.posting_id = 9999;

-- orphane postings
select
    p.posting_id,
    p.employer_id,
    e.employer_id as matching_employer
from postings p
left join employers e
    on p.employer_id = e.employer_id
where e.employer_id is null;

-- duplicate applications
select
    candidate_id,
    posting_id,
    application_date,
    count(*) as duplicate_count
from applications
group by
    candidate_id,
    posting_id,
    application_date
having count(*) > 1;


-- application before posting date
select
    a.application_id,
    a.posting_id,
    a.application_date,
    p.posted_date
from applications a
join postings p
    on a.posting_id = p.posting_id
where a.application_date < p.posted_date;

-- scorecard query
with Data_Quality_Checks as (

    -- candidates: missing city
    select
        'candidates' as table_name,
        'missing city' as check_name,
        count(*) as failed_records
    from candidates
    where city is null
       or trim(city) = ''

    union all

    -- candidates: phone number in email
    select
        'candidates',
        'phone number in email',
        count(*)
    from candidates
    where email ~ '^[0-9]+$'

    union all

    -- candidates: invalid email
    select
        'candidates',
        'invalid email',
        count(*)
    from candidates
    where email is not null
      and email !~ '^[a-za-z0-9._%+-]+@[a-za-z0-9.-]+\.[a-za-z]{2,}$'

    union all

    -- employers: duplicate email
    select
        'employers',
        'duplicate email',
        count(*)
    from (
        select email
        from employers
        where email is not null
        group by email
        having count(*) > 1
    ) duplicates

    union all

    -- employers: missing phone
    select
        'employers',
        'missing phone',
        count(*)
    from employers
    where phone is null
       or trim(phone) = ''

    union all

    -- postings: orphan employer
    select
        'postings',
        'orphan employer',
        count(*)
    from postings p
    left join employers e
        on p.employer_id = e.employer_id
    where e.employer_id is null

    union all

    -- applications: orphan posting
    select
        'applications',
        'orphan posting',
        count(*)
    from applications a
    left join postings p
        on a.posting_id = p.posting_id
    where p.posting_id is null

    union all

    -- applications: duplicate applications
    select
        'applications',
        'duplicate application',
        count(*)
    from (
        select candidate_id, posting_id, application_date
        from applications
        group by candidate_id, posting_id, application_date
        having count(*) > 1
    ) duplicates

    union all

    -- applications: application before posting
    select
        'applications',
        'application before posting',
        count(*)
    from applications a
    join postings p
        on a.posting_id = p.posting_id
    where a.application_date < p.posted_date
)

select
    table_name,
    check_name,
    failed_records,
    case
        when failed_records = 0 then 'pass'
        else 'fail'
    end as status
from Data_Quality_Checks
order by table_name, check_name;


-- table-level health score
with Data_Quality_Checks as (

    select
        'candidates' as table_name,
        'missing city' as check_name,
        count(*) as failed_records
    from candidates
    where city is null
       or trim(city) = ''

    union all

    select
        'candidates',
        'phone number in email',
        count(*)
    from candidates
    where email ~ '^[0-9]+$'

    union all

    select
        'candidates',
        'invalid email',
        count(*)
    from candidates
    where email is not null
      and email !~ '^[a-za-z0-9._%+-]+@[a-za-z0-9.-]+\.[a-za-z]{2,}$'

    union all

    select
        'employers',
        'duplicate email',
        count(*)
    from (
        select email
        from employers
        where email is not null
        group by email
        having count(*) > 1
    ) duplicates

    union all

    select
        'employers',
        'missing phone',
        count(*)
    from employers
    where phone is null
       or trim(phone) = ''

    union all

    select
        'postings',
        'orphan employer',
        count(*)
    from postings p
    left join employers e
        on p.employer_id = e.employer_id
    where e.employer_id is null

    union all

    select
        'applications',
        'orphan posting',
        count(*)
    from applications a
    left join postings p
        on a.posting_id = p.posting_id
    where p.posting_id is null

    union all

    select
        'applications',
        'duplicate application',
        count(*)
    from (
        select candidate_id, posting_id, application_date
        from applications
        group by candidate_id, posting_id, application_date
        having count(*) > 1
    ) duplicates

    union all

    select
        'applications',
        'application before posting',
        count(*)
    from applications a
    join postings p
        on a.posting_id = p.posting_id
    where a.application_date < p.posted_date
),

table_scores as (
    select
        table_name,
        count(*) as total_checks,
        count(*) filter (where failed_records = 0) as passed_checks,
        count(*) filter (where failed_records > 0) as failed_checks
    from Data_Quality_Checks
    group by table_name
)

select
    table_name,
    total_checks,
    passed_checks,
    failed_checks,
    round(
        passed_checks * 100.0 / total_checks,
        2
    ) as health_score
from table_scores
order by table_name;

