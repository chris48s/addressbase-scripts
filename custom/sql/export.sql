SELECT
  DISTINCT ON (b.uprn)
  b.uprn AS uprn,

  /*
  Concatenate a single GEOGRAPHIC address line label
  This code takes into account all possible combinations
  of PAO/SAO numbers and suffixes.
  */
  TRIM(
    CASE
      WHEN
        o.organisation IS NOT NULL
      THEN
        o.organisation || ' '
      ELSE
        ''
    END
    --Secondary Addressable Information
    ||
    CASE
      WHEN
        l.sao_text IS NOT NULL
      THEN
        l.sao_text || ' '
      ELSE
        ''
    END
    --case statement for different combinations of the sao start numbers
    --(e.g. if no sao start suffix)
    ||
    CASE
      WHEN
        l.sao_start_number IS NOT NULL
        AND l.sao_start_suffix IS NULL
        AND l.sao_end_number IS NULL
      THEN
        l.sao_start_number::VARCHAR(4) || ' '
      WHEN
        l.sao_start_number IS NULL
      THEN
        ''
      ELSE
        l.sao_start_number::VARCHAR(4) || ''
    END
    --case statement for different combinations of the sao start suffixes
    --(e.g. if no sao end number)
    ||
    CASE
      WHEN
        l.sao_start_suffix IS NOT NULL
        AND l.sao_end_number IS NULL
      THEN
        l.sao_start_suffix || ' '
      WHEN
        l.sao_start_suffix IS NOT NULL
        AND l.sao_end_number IS NOT NULL
      THEN
        l.sao_start_suffix
      ELSE
        ''
    END
    --Add a '-' between the start and end of the secondary address
    --(e.g. only when sao start and sao end)
    ||
    CASE
      WHEN
        l.sao_end_suffix IS NOT NULL
        AND l.sao_end_number IS NOT NULL
      THEN
        '-'
      WHEN
        l.sao_start_number IS NOT NULL
        AND l.sao_end_number IS NOT NULL
      THEN
        '-'
      ELSE
        ''
    END
    --case statement for different combinations of the
    --sao end numbers and sao end suffixes
    ||
    CASE
      WHEN
        l.sao_end_number IS NOT NULL
        AND l.sao_end_suffix IS NULL
      THEN
        l.sao_end_number::VARCHAR(4) || ' '
      WHEN
        l.sao_end_number IS NULL
      THEN
        ''
      ELSE
        l.sao_end_number::VARCHAR(4)
    END
    --pao end suffix
    ||
    CASE
      WHEN
        l.sao_end_suffix IS NOT NULL
      THEN
        l.sao_end_suffix || ' '
      ELSE
        ''
    END
    --Primary Addressable Information
    ||
    CASE
      WHEN
        l.pao_text IS NOT NULL
      THEN
        l.pao_text || ' '
      ELSE
        ''
    END
    --case statement for different combinations of the pao start numbers
    --(e.g. if no pao start suffix)
    ||
    CASE
      WHEN
        l.pao_start_number IS NOT NULL
        AND l.pao_start_suffix IS NULL
        AND l.pao_end_number IS NULL
      THEN
        l.pao_start_number::VARCHAR(4) || ' '
      WHEN
        l.pao_start_number IS NULL
      THEN
        ''
      ELSE
        l.pao_start_number::VARCHAR(4) || ''
    END
    --case statement for different combinations of the pao start suffixes
    --(e.g. if no pao end number)
    ||
    CASE
      WHEN
        l.pao_start_suffix IS NOT NULL
        AND l.pao_end_number IS NULL
      THEN
        l.pao_start_suffix || ' '
      WHEN
        l.pao_start_suffix IS NOT NULL
        AND l.pao_end_number IS NOT NULL
      THEN
        l.pao_start_suffix
      ELSE
        ''
    END
    --Add a '-' between the start and end of the primary address
    --(e.g. only when pao start and pao end)
    ||
    CASE
      WHEN
        l.pao_end_suffix IS NOT NULL
        AND l.pao_end_number IS NOT NULL
      THEN
        '-'
      WHEN
        l.pao_start_number IS NOT NULL
        AND l.pao_end_number IS NOT NULL
      THEN
        '-'
      ELSE
        ''
    END
    --case statement for different combinations of the
    --pao end numbers and pao end suffixes
    ||
    CASE
      WHEN
        l.pao_end_number IS NOT NULL
        AND l.pao_end_suffix IS NULL
      THEN
        l.pao_end_number::VARCHAR(4) || ' '
      WHEN
        l.pao_end_number IS NULL
      THEN
        ''
      ELSE
        l.pao_end_number::VARCHAR(4)
    END
    --pao end suffix
    ||
    CASE
      WHEN
        l.pao_end_suffix IS NOT NULL
      THEN
        l.pao_end_suffix || ' '
      ELSE
        ''
    END
    --Street Information
    ||
    CASE
      WHEN
        s.street_description IS NOT NULL
      THEN
        s.street_description || ', '
      ELSE
        ''
    END
    --Locality
    ||
    CASE
      WHEN
        s.locality IS NOT NULL
      THEN
        s.locality || ', '
      ELSE
        ''
    END
    --Town
    ||
    CASE
      WHEN
        s.town_name IS NOT NULL
      THEN
        s.town_name || ' '
      ELSE
        ''
    END
  ) AS full_address,

  b.postcode_locator AS postcode,

  'SRID=4326;POINT(' || longitude || ' ' || latitude || ')' AS location

FROM
  abp_blpu AS b
  JOIN
    abp_lpi AS l
    ON b.uprn = l.uprn
    AND l.language = 'ENG'
  JOIN
    abp_street_descriptor AS s
    ON l.usrn = s.usrn
    AND s.language = 'ENG'
  LEFT JOIN
    abp_organisation o
    ON b.uprn = o.uprn
WHERE
  l.end_date IS NULL
  AND b.end_date IS NULL
  AND o.end_date IS NULL
  AND s.end_date IS NULL
  /*
  Only include type C and L UPRNs
  We'll pick up the type Ds from AddressBase standard
  and we want to exclude type N UPRNs
  */
  AND b.addressbase_postal IN ('C', 'L')
  -- Allow Approved UPRNs but exclude Historical and Provisional
  AND b.logical_status = 1
  AND l.logical_status = b.logical_status
ORDER BY
  b.uprn ASC,
  /*
  Ordering is very significant here.
  Becuase we're using `DISTINCT ON (b.uprn)` this ensures that if
  there is a duplicate we pick the most recent by start date(s)

  If we've got no end date and an identical start date for the
  BLPU, LPI, Street Descriptor and Organisation,
  we essentially just give up and pick one at random.
  */
  b.start_date DESC,
  l.start_date DESC,
  s.start_date DESC,
  o.start_date DESC
