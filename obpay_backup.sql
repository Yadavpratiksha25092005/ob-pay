--
-- PostgreSQL database dump
--

\restrict PhXNzhkaRyDTpbktCQod5nl9GhRPYdNAh1VhhB0krnUUfcZJImPQ3PT7AEt5ExK

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aml_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aml_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    transaction_id uuid,
    amount numeric(15,2) NOT NULL,
    report_type character varying(10) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.aml_reports OWNER TO postgres;

--
-- Name: beneficiaries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.beneficiaries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(15) NOT NULL,
    nickname character varying(50) DEFAULT ''::character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.beneficiaries OWNER TO postgres;

--
-- Name: compliance_checks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compliance_checks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    transaction_id uuid,
    check_type character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'passed'::character varying,
    risk_score integer DEFAULT 0,
    risk_level character varying(10) DEFAULT 'low'::character varying,
    reason text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.compliance_checks OWNER TO postgres;

--
-- Name: disputes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.disputes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    transaction_id uuid NOT NULL,
    type character varying(30) NOT NULL,
    status character varying(20) DEFAULT 'open'::character varying,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    amount numeric(15,2) NOT NULL,
    resolution text,
    resolved_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.disputes OWNER TO postgres;

--
-- Name: fraud_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fraud_alerts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    transaction_id uuid,
    alert_type character varying(30) NOT NULL,
    severity character varying(10) DEFAULT 'low'::character varying,
    description text,
    is_resolved boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.fraud_alerts OWNER TO postgres;

--
-- Name: kyc_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    document_type character varying(30) NOT NULL,
    document_number character varying(50) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    rejection_reason text,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.kyc_documents OWNER TO postgres;

--
-- Name: kyc_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    full_name character varying(255) NOT NULL,
    date_of_birth character varying(20),
    gender character varying(10),
    address text,
    aadhaar_number character varying(20),
    pan_number character varying(20),
    kyc_status character varying(20) DEFAULT 'pending'::character varying,
    risk_level character varying(10) DEFAULT 'low'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.kyc_profiles OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type character varying(20) NOT NULL,
    category character varying(30) NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: offers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.offers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(100) NOT NULL,
    subtitle text,
    code character varying(50),
    category character varying(50),
    discount_type character varying(20),
    discount_value double precision,
    min_amount double precision DEFAULT 0,
    valid_till timestamp without time zone,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.offers OWNER TO postgres;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sender_user_id uuid,
    receiver_user_id uuid,
    amount numeric(15,2) NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying,
    status character varying(20) DEFAULT 'pending'::character varying,
    description text,
    created_at timestamp without time zone DEFAULT now(),
    payment_method character varying(20) DEFAULT 'wallet'::character varying NOT NULL
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(64) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: reward_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reward_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    event_type character varying(50) NOT NULL,
    ref_id character varying(100) DEFAULT ''::character varying NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.reward_events OWNER TO postgres;

--
-- Name: reward_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reward_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    points integer NOT NULL,
    type character varying(20) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.reward_transactions OWNER TO postgres;

--
-- Name: settlements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.settlements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    amount numeric(15,2) NOT NULL,
    fee numeric(15,2) DEFAULT 0,
    net_amount numeric(15,2) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    bank_account character varying(50) NOT NULL,
    ifsc_code character varying(20) NOT NULL,
    bank_name character varying(100) NOT NULL,
    utr_number character varying(50),
    settlement_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.settlements OWNER TO postgres;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type character varying(20) NOT NULL,
    amount numeric(15,2) NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying,
    status character varying(20) DEFAULT 'pending'::character varying,
    reference_id uuid,
    description text,
    sender_user_id uuid,
    receiver_user_id uuid,
    payment_method character varying(20) DEFAULT 'wallet'::character varying,
    balance_before numeric(15,2) DEFAULT 0,
    balance_after numeric(15,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: user_rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_rewards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    points integer DEFAULT 0,
    total_earned integer DEFAULT 0,
    total_redeemed integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_rewards OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    phone character varying(15) NOT NULL,
    email character varying(255),
    full_name character varying(255) NOT NULL,
    pin_hash character varying(255) NOT NULL,
    kyc_status character varying(20) DEFAULT 'pending'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    fcm_token text DEFAULT ''::text,
    role character varying(20) DEFAULT 'customer'::character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: wallets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    balance numeric(15,2) DEFAULT 0.00,
    currency character varying(3) DEFAULT 'INR'::character varying,
    is_frozen boolean DEFAULT false,
    daily_limit numeric(15,2) DEFAULT 10000.00,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.wallets OWNER TO postgres;

--
-- Data for Name: aml_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aml_reports (id, user_id, transaction_id, amount, report_type, status, description, created_at) FROM stdin;
\.


--
-- Data for Name: beneficiaries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.beneficiaries (id, user_id, name, phone, nickname, created_at) FROM stdin;
\.


--
-- Data for Name: compliance_checks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compliance_checks (id, user_id, transaction_id, check_type, status, risk_score, risk_level, reason, created_at) FROM stdin;
\.


--
-- Data for Name: disputes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.disputes (id, user_id, transaction_id, type, status, title, description, amount, resolution, resolved_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: fraud_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fraud_alerts (id, user_id, transaction_id, alert_type, severity, description, is_resolved, created_at) FROM stdin;
\.


--
-- Data for Name: kyc_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kyc_documents (id, user_id, document_type, document_number, status, rejection_reason, verified_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: kyc_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kyc_profiles (id, user_id, full_name, date_of_birth, gender, address, aadhaar_number, pan_number, kyc_status, risk_level, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, category, title, message, status, is_read, created_at) FROM stdin;
194170f9-d5cc-4583-8447-1d2d982a8637	acc49a78-f065-4373-9341-40d060126b7a	push	payment	Payment Received!	You have received Rs 500 from Test User. Transaction ID: TXN123	sent	t	2026-06-18 13:19:23.728666
07079eee-4b91-4bde-a672-1f0e4787c8ab	acc49a78-f065-4373-9341-40d060126b7a	push	payment	Payment Sent Successfully	₹500.00 sent to Test User successfully! Transaction ID: test-payment-123	sent	t	2026-06-17 12:43:23.354164
f68fb929-31f2-46fe-8095-cad5a4d16c1d	2a681dd3-d4c2-4cc6-a521-5501793f6ee3	push	admin	New Feature!	Check out our new rewards program	sent	f	2026-06-22 11:24:46.795312
6a7f7463-a628-4aff-afe8-f342e3a9efc6	158cfeae-7834-4fe3-ae83-b49b8c30c764	push	admin	New Feature!	Check out our new rewards program	sent	f	2026-06-22 11:24:46.817431
89da76d2-99d0-4c7e-b810-323bbfda7645	35285ab9-ad01-404d-86d0-223b25b0eb4b	push	admin	New Feature!	Check out our new rewards program	sent	f	2026-06-22 11:24:46.828082
932a11ea-cfde-4e12-9ed8-bb0b7957030b	8c152412-9782-498b-88c6-575dbf16e670	push	admin	New Feature!	Check out our new rewards program	sent	f	2026-06-22 11:24:46.841188
8edc3794-067d-4a87-a2a5-8f40a34fb58a	acc49a78-f065-4373-9341-40d060126b7a	push	admin	New Feature!	Check out our new rewards program	sent	f	2026-06-22 11:24:46.849911
f285a3b9-784d-4c1f-8d80-e10fee93501e	35285ab9-ad01-404d-86d0-223b25b0eb4b	push	admin	KYC Approved! ✅	Congratulations! Your KYC has been verified. You can now access all OB Pay features.	sent	f	2026-06-22 13:02:55.346319
6079e3db-a907-4e2a-967f-ce9b476101cd	35285ab9-ad01-404d-86d0-223b25b0eb4b	push	admin	KYC Approved! ✅	Congratulations! Your KYC has been verified. You can now access all OB Pay features.	sent	f	2026-06-22 13:04:07.9511
383a0082-41c5-4b60-ba2f-117ec65f4af7	35285ab9-ad01-404d-86d0-223b25b0eb4b	push	admin	KYC Approved! ✅	Congratulations! Your KYC has been verified. You can now access all OB Pay features.	sent	f	2026-06-22 13:16:34.441912
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.offers (id, title, subtitle, code, category, discount_type, discount_value, min_amount, valid_till, is_active, created_at) FROM stdin;
7fcbef52-fac8-4be9-b100-5db9de4579d1	Flat ₹75 Cashback	on Electricity Bill Payment	SAVE75	electricity	flat	75	500	2026-07-19 16:15:40.628602	t	2026-06-19 16:15:40.629675
8fd02337-800e-4c11-9346-d28e9a2886f7	Upto ₹100 Cashback	on Mobile Recharge	RECHARGE100	recharge	flat	100	199	2026-07-19 16:15:40.631238	t	2026-06-19 16:15:40.631484
43594310-dcbf-446d-94a7-8047c4d0c9a5	Get 10% Cashback	on DTH Recharge	DTH10	dth	percent	10	149	2026-07-19 16:15:40.631238	t	2026-06-19 16:15:40.631933
1bc8a312-8147-4cf5-9fb9-125e967858d4	Flat ₹50 Cashback	on Bill Payments	BILL50	bills	flat	50	200	2026-07-19 16:15:40.631759	t	2026-06-19 16:15:40.632398
f79d5b9e-4832-4caf-82d4-40a53e0380a4	Free Transfer	Send money up to ₹1,000	FREE1K	transfer	flat	0	0	2026-07-19 16:15:40.632288	t	2026-06-19 16:15:40.632848
8199d860-de7f-4257-9760-80f8ed64f32b	₹25 Cashback	on First UPI Payment	FIRST25	upi	flat	25	100	2026-07-19 16:15:40.632806	t	2026-06-19 16:15:40.633287
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, sender_user_id, receiver_user_id, amount, currency, status, description, created_at, payment_method) FROM stdin;
434143de-d4ba-4cdc-b243-c5c16ddf4c21	acc49a78-f065-4373-9341-40d060126b7a	8c152412-9782-498b-88c6-575dbf16e670	500.00	INR	success	Test paymemt	2026-06-16 16:10:38.436492	wallet
d80198fb-a3bb-4947-ac2b-9fe208c6cb49	acc49a78-f065-4373-9341-40d060126b7a	acc49a78-f065-4373-9341-40d060126b7a	100.00	INR	success		2026-06-18 12:04:53.837376	wallet
1e8e100c-b375-429e-98fd-f7dd4c821f51	acc49a78-f065-4373-9341-40d060126b7a	8c152412-9782-498b-88c6-575dbf16e670	500.00	INR	success		2026-06-18 12:06:20.835504	wallet
ac69cd9b-e8a8-4fe6-86e0-f0bb68daff8c	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	500.00	INR	success		2026-06-18 12:13:03.861843	wallet
4b86f9d4-47e0-42da-8646-299c9085f384	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	500.00	INR	success		2026-06-19 10:49:00.48886	wallet
bfbc7857-239a-4767-80ea-2ff66e875d7a	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	500.00	INR	success		2026-06-19 16:12:50.680224	wallet
9b9d85f8-6d77-4970-bb16-f505cf575f55	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	500.00	INR	success		2026-06-19 17:55:02.408171	wallet
48a3dc65-49b4-429f-b4dd-b5ccf9e00cde	acc49a78-f065-4373-9341-40d060126b7a	acc49a78-f065-4373-9341-40d060126b7a	500.00	INR	success	Cash In by Agent	2026-06-20 11:18:54.889092	wallet
41c3d280-b799-45f0-93e8-d539a399afac	acc49a78-f065-4373-9341-40d060126b7a	8c152412-9782-498b-88c6-575dbf16e670	500.00	INR	success	Cash Out by Agent	2026-06-20 11:24:04.72306	wallet
316a9f15-3b10-4c3f-b7a9-d4e04ff0c42d	8c152412-9782-498b-88c6-575dbf16e670	158cfeae-7834-4fe3-ae83-b49b8c30c764	500.00	INR	success	Cash Out via Agent	2026-06-20 11:57:31.227524	wallet
32183269-c9b7-454e-b49c-890b7eb3d89c	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	100.00	INR	success		2026-06-22 08:18:18.973294	wallet
bb969126-34c7-4abd-a174-71ad9b878137	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	100.00	INR	success		2026-06-22 09:20:59.620135	wallet
d8c006a9-ee5f-48c3-929d-82da4d3e7ade	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	100.00	INR	success		2026-06-22 09:40:15.388357	wallet
a72bb535-ef53-4c85-84c2-83699b38edff	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	100.00	INR	success		2026-06-22 09:42:07.261719	wallet
0a132ffb-1367-42a5-83c9-df5d97029c21	acc49a78-f065-4373-9341-40d060126b7a	35285ab9-ad01-404d-86d0-223b25b0eb4b	100.00	INR	success		2026-06-22 10:12:52.129108	wallet
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, revoked_at, created_at) FROM stdin;
\.


--
-- Data for Name: reward_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward_events (id, user_id, event_type, ref_id, points, created_at) FROM stdin;
\.


--
-- Data for Name: reward_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward_transactions (id, user_id, points, type, description, created_at) FROM stdin;
\.


--
-- Data for Name: settlements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.settlements (id, merchant_id, amount, fee, net_amount, status, bank_account, ifsc_code, bank_name, utr_number, settlement_date, created_at, updated_at) FROM stdin;
428c0a23-11a0-4f67-afe6-23e530d90098	acc49a78-f065-4373-9341-40d060126b7a	500.00	5.00	495.00	pending	1234567890	HDFC0001234	HDFC Bank	\N	\N	2026-06-17 12:51:49.340291	2026-06-17 12:51:49.340291
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, user_id, type, amount, currency, status, reference_id, description, sender_user_id, receiver_user_id, payment_method, balance_before, balance_after, created_at, updated_at) FROM stdin;
eda69bcc-77a3-4d7c-b33e-abe19cc96813	acc49a78-f065-4373-9341-40d060126b7a	credit	500.00	INR	success	\N	Test transaction	acc49a78-f065-4373-9341-40d060126b7a	8c152412-9782-498b-88c6-575dbf16e670	wallet	1000.00	500.00	2026-06-17 12:36:24.470323	2026-06-17 12:36:24.470323
\.


--
-- Data for Name: user_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_rewards (id, user_id, points, total_earned, total_redeemed, created_at, updated_at) FROM stdin;
7d7aae5d-8877-4af8-8270-e190eba96094	acc49a78-f065-4373-9341-40d060126b7a	1250	1250	0	2026-06-19 16:16:15.389335	2026-06-19 16:16:15.389335
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, phone, email, full_name, pin_hash, kyc_status, is_active, created_at, updated_at, fcm_token, role) FROM stdin;
8c152412-9782-498b-88c6-575dbf16e670	9999999999	receiver@obpay.com	Receiver User	$2a$10$mmJOOPsgIfrxmgVcW52ynuWJTu.9CxRjwq8CBMy8iY37jhPIEh8p.	pending	t	2026-06-16 16:06:03.509629	2026-06-16 16:06:03.509629		customer
acc49a78-f065-4373-9341-40d060126b7a	9876543210	test@obpay.com	Test User	$2a$10$SgBAhy9m/Cs9SiUVow84ZOTG9UduZV15vWpoVEIyLOFhFeFsAjXcu	pending	t	2026-06-16 15:29:30.319438	2026-06-16 15:29:30.319438	c1r34ja_TKi-GxMVOrwAWq:APA91bHk43wifRxim3luy55vfOyV-PBQiX3MGGszw-HMb0vmf3yw6YmJH2WLjX4bn6qjJPBhv9uqRYPq0e4W1k0pvMU_WLsP0hNf3fbPp4oAtd32apUNR78	customer
35285ab9-ad01-404d-86d0-223b25b0eb4b	8888888888	merchant@obpay.com	Merchant User	$2a$10$xhSYIRVyGjYUt5XdMCvqeON1FOVRL81rHLiRw9wv1e4lsnkWAmuqC	pending	t	2026-06-18 12:09:11.183594	2026-06-18 12:09:11.183594	cDVbOlQjQCq5UGEqMX0SkJ:APA91bHOas6068C-8lIK0KKsiSAwISbaLUGoigT_IsM2YdI-V22d0FvYpeDDms8Nzw3F4l5EClwQXZUYHmEq-1jmrHkocmkiPIjG-alTkc6EnxfjzF3V9ew	merchant
158cfeae-7834-4fe3-ae83-b49b8c30c764	7777777777	pratiksha@gmail.com 	pratiksha 	$2a$10$7FCm/ufRiy7ywusnRHGmieI037Oxu.QzC2PTFiqs1wPafHTpVqLIa	pending	t	2026-06-20 11:55:27.302857	2026-06-20 11:55:27.302857		agent
2a681dd3-d4c2-4cc6-a521-5501793f6ee3	9000000000	shubham@gmail.com	shubham	$2a$10$syzG7oxDUnjlpMv5ZMQg8OXZj9DHT.mNaReLh8drhsORKE44MlP9e	pending	t	2026-06-22 10:41:15.716936	2026-06-22 10:41:15.716936	c1r34ja_TKi-GxMVOrwAWq:APA91bHk43wifRxim3luy55vfOyV-PBQiX3MGGszw-HMb0vmf3yw6YmJH2WLjX4bn6qjJPBhv9uqRYPq0e4W1k0pvMU_WLsP0hNf3fbPp4oAtd32apUNR78	customer
\.


--
-- Data for Name: wallets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wallets (id, user_id, balance, currency, is_frozen, daily_limit, created_at) FROM stdin;
0e5700df-e31f-45d7-8e14-d12f691bf32b	8c152412-9782-498b-88c6-575dbf16e670	1000.00	INR	f	10000.00	2026-06-16 16:07:37.453849
0740b6ac-23de-4814-aa52-bf896510cda3	158cfeae-7834-4fe3-ae83-b49b8c30c764	10500.00	INR	f	50000.00	2026-06-20 11:57:02.52292
14e9d733-98da-483b-9589-ffe368baf4c6	acc49a78-f065-4373-9341-40d060126b7a	9500.00	INR	f	10000.00	2026-06-16 15:41:19.41981
1c59f630-1a05-4e99-b67e-1551a91404c4	35285ab9-ad01-404d-86d0-223b25b0eb4b	2500.00	INR	f	10000.00	2026-06-18 12:09:57.335086
\.


--
-- Name: aml_reports aml_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aml_reports
    ADD CONSTRAINT aml_reports_pkey PRIMARY KEY (id);


--
-- Name: beneficiaries beneficiaries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beneficiaries
    ADD CONSTRAINT beneficiaries_pkey PRIMARY KEY (id);


--
-- Name: beneficiaries beneficiaries_user_id_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beneficiaries
    ADD CONSTRAINT beneficiaries_user_id_phone_key UNIQUE (user_id, phone);


--
-- Name: compliance_checks compliance_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compliance_checks
    ADD CONSTRAINT compliance_checks_pkey PRIMARY KEY (id);


--
-- Name: disputes disputes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disputes
    ADD CONSTRAINT disputes_pkey PRIMARY KEY (id);


--
-- Name: fraud_alerts fraud_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fraud_alerts
    ADD CONSTRAINT fraud_alerts_pkey PRIMARY KEY (id);


--
-- Name: kyc_documents kyc_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_pkey PRIMARY KEY (id);


--
-- Name: kyc_profiles kyc_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_profiles
    ADD CONSTRAINT kyc_profiles_pkey PRIMARY KEY (id);


--
-- Name: kyc_profiles kyc_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_profiles
    ADD CONSTRAINT kyc_profiles_user_id_key UNIQUE (user_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: offers offers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: reward_events reward_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reward_events
    ADD CONSTRAINT reward_events_pkey PRIMARY KEY (id);


--
-- Name: reward_events reward_events_user_id_event_type_ref_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reward_events
    ADD CONSTRAINT reward_events_user_id_event_type_ref_id_key UNIQUE (user_id, event_type, ref_id);


--
-- Name: reward_transactions reward_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reward_transactions
    ADD CONSTRAINT reward_transactions_pkey PRIMARY KEY (id);


--
-- Name: settlements settlements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settlements
    ADD CONSTRAINT settlements_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards user_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- Name: idx_aml_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aml_user_id ON public.aml_reports USING btree (user_id);


--
-- Name: idx_beneficiaries_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_beneficiaries_user ON public.beneficiaries USING btree (user_id);


--
-- Name: idx_compliance_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_compliance_user ON public.compliance_checks USING btree (user_id);


--
-- Name: idx_compliance_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_compliance_user_id ON public.compliance_checks USING btree (user_id);


--
-- Name: idx_disputes_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_disputes_status ON public.disputes USING btree (status);


--
-- Name: idx_disputes_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_disputes_transaction_id ON public.disputes USING btree (transaction_id);


--
-- Name: idx_disputes_tx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_disputes_tx ON public.disputes USING btree (transaction_id);


--
-- Name: idx_disputes_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_disputes_user ON public.disputes USING btree (user_id);


--
-- Name: idx_disputes_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_disputes_user_id ON public.disputes USING btree (user_id);


--
-- Name: idx_fraud_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fraud_user_id ON public.fraud_alerts USING btree (user_id);


--
-- Name: idx_kyc_docs_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kyc_docs_user ON public.kyc_documents USING btree (user_id);


--
-- Name: idx_kyc_documents_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kyc_documents_user_id ON public.kyc_documents USING btree (user_id);


--
-- Name: idx_kyc_profiles_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kyc_profiles_user_id ON public.kyc_profiles USING btree (user_id);


--
-- Name: idx_kyc_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kyc_user ON public.kyc_profiles USING btree (user_id);


--
-- Name: idx_notifications_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_is_read ON public.notifications USING btree (is_read);


--
-- Name: idx_notifications_unread; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_unread ON public.notifications USING btree (user_id, is_read) WHERE (is_read = false);


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_payments_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_created ON public.payments USING btree (created_at DESC);


--
-- Name: idx_payments_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_receiver ON public.payments USING btree (receiver_user_id);


--
-- Name: idx_payments_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_sender ON public.payments USING btree (sender_user_id);


--
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- Name: idx_refresh_tokens_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_tokens_hash ON public.refresh_tokens USING btree (token_hash);


--
-- Name: idx_refresh_tokens_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_tokens_user ON public.refresh_tokens USING btree (user_id);


--
-- Name: idx_reward_events_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reward_events_user ON public.reward_events USING btree (user_id);


--
-- Name: idx_reward_tx_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reward_tx_user ON public.reward_transactions USING btree (user_id);


--
-- Name: idx_rewards_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rewards_user ON public.user_rewards USING btree (user_id);


--
-- Name: idx_settlements_merchant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_settlements_merchant ON public.settlements USING btree (merchant_id);


--
-- Name: idx_settlements_merchant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_settlements_merchant_id ON public.settlements USING btree (merchant_id);


--
-- Name: idx_settlements_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_settlements_status ON public.settlements USING btree (status);


--
-- Name: idx_transactions_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_created ON public.transactions USING btree (created_at DESC);


--
-- Name: idx_transactions_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_created_at ON public.transactions USING btree (created_at);


--
-- Name: idx_transactions_ref; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_ref ON public.transactions USING btree (reference_id);


--
-- Name: idx_transactions_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_status ON public.transactions USING btree (status);


--
-- Name: idx_transactions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_user ON public.transactions USING btree (user_id);


--
-- Name: idx_transactions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_user_id ON public.transactions USING btree (user_id);


--
-- Name: idx_users_phone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_phone ON public.users USING btree (phone);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: idx_wallets_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wallets_user ON public.wallets USING btree (user_id);


--
-- Name: beneficiaries beneficiaries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beneficiaries
    ADD CONSTRAINT beneficiaries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_receiver_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_receiver_user_id_fkey FOREIGN KEY (receiver_user_id) REFERENCES public.users(id);


--
-- Name: payments payments_sender_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_sender_user_id_fkey FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reward_events reward_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reward_events
    ADD CONSTRAINT reward_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: wallets wallets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict PhXNzhkaRyDTpbktCQod5nl9GhRPYdNAh1VhhB0krnUUfcZJImPQ3PT7AEt5ExK

