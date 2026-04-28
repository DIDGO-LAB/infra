USE user_db;

CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    login_id VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender ENUM('MALE', 'FEMALE', 'NONE') NULL,
    email VARCHAR(255) NOT NULL,
    desired_job VARCHAR(100) NULL,
    status ENUM('ACTIVE', 'LOCKED', 'WITHDRAWN') NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NULL,
    last_login_at DATETIME NULL,
    UNIQUE KEY uk_users_login_id (login_id),
    UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_disabilities (
    disability_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    disability_type VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_user_disabilities_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT uk_user_disabilities_user_type
        UNIQUE (user_id, disability_type)
) ENGINE=InnoDB;

USE training_db;

CREATE TABLE IF NOT EXISTS training_sessions (
    session_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    training_type ENUM('SOCIAL', 'SAFETY', 'FOCUS', 'DOCUMENT') NOT NULL,
    sub_type VARCHAR(50) NULL,
    scenario_id BIGINT NULL,
    status ENUM('IN_PROGRESS', 'COMPLETED', 'FAILED') NOT NULL,
    current_step INT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NULL,
    CONSTRAINT chk_training_sessions_focus_sub_type
        CHECK (training_type <> 'FOCUS' OR sub_type IS NOT NULL),
    KEY idx_training_sessions_user_type_started (user_id, training_type, started_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS training_scores (
    score_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT NOT NULL,
    score INT NOT NULL,
    score_type ENUM('AI_EVALUATION', 'ACCURACY_RATE', 'REACTION_PERFORMANCE', 'CHOICE_RESULT') NOT NULL,
    correct_count INT NULL,
    total_count INT NULL,
    accuracy_rate DECIMAL(5,2) NULL,
    wrong_count INT NULL,
    average_reaction_ms INT NULL,
    raw_metrics_json JSON NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_training_scores_session
        FOREIGN KEY (session_id) REFERENCES training_sessions(session_id),
    CONSTRAINT uk_training_scores_session
        UNIQUE (session_id),
    CONSTRAINT chk_training_scores_score
        CHECK (score BETWEEN 0 AND 100),
    CONSTRAINT chk_training_scores_correct_count
        CHECK (correct_count IS NULL OR correct_count >= 0),
    CONSTRAINT chk_training_scores_total_count
        CHECK (total_count IS NULL OR total_count >= 0),
    CONSTRAINT chk_training_scores_accuracy_rate
        CHECK (accuracy_rate IS NULL OR accuracy_rate BETWEEN 0 AND 100),
    CONSTRAINT chk_training_scores_wrong_count
        CHECK (wrong_count IS NULL OR wrong_count >= 0),
    CONSTRAINT chk_training_scores_reaction
        CHECK (average_reaction_ms IS NULL OR average_reaction_ms >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS training_feedbacks (
    feedback_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT NOT NULL,
    feedback_type ENUM('SUMMARY', 'DETAIL', 'RECOMMENDATION') NOT NULL,
    feedback_source ENUM('AI', 'SYSTEM') NOT NULL,
    summary VARCHAR(255) NOT NULL,
    detail_text TEXT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_training_feedbacks_session
        FOREIGN KEY (session_id) REFERENCES training_sessions(session_id),
    KEY idx_training_feedbacks_session (session_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS training_session_summaries (
    summary_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    training_type ENUM('SOCIAL', 'SAFETY', 'FOCUS', 'DOCUMENT') NOT NULL,
    scenario_id BIGINT NULL,
    scenario_title VARCHAR(255) NULL,
    category ENUM('SEXUAL_EDUCATION', 'INFECTIOUS_DISEASE', 'COMMUTE_SAFETY') NULL,
    title VARCHAR(255) NOT NULL,
    score INT NULL,
    summary_text TEXT NULL,
    feedback_summary VARCHAR(255) NULL,
    correct_count INT NULL,
    total_count INT NULL,
    accuracy_rate DECIMAL(5,2) NULL,
    wrong_count INT NULL,
    played_level INT NULL,
    average_reaction_ms INT NULL,
    completed_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_training_session_summaries_session
        FOREIGN KEY (session_id) REFERENCES training_sessions(session_id),
    CONSTRAINT uk_training_session_summaries_session
        UNIQUE (session_id),
    CONSTRAINT chk_training_session_summaries_score
        CHECK (score IS NULL OR score BETWEEN 0 AND 100),
    CONSTRAINT chk_training_session_summaries_correct_count
        CHECK (correct_count IS NULL OR correct_count >= 0),
    CONSTRAINT chk_training_session_summaries_total_count
        CHECK (total_count IS NULL OR total_count >= 0),
    CONSTRAINT chk_training_session_summaries_accuracy
        CHECK (accuracy_rate IS NULL OR accuracy_rate BETWEEN 0 AND 100),
    CONSTRAINT chk_training_session_summaries_wrong_count
        CHECK (wrong_count IS NULL OR wrong_count >= 0),
    CONSTRAINT chk_training_session_summaries_played_level
        CHECK (played_level IS NULL OR played_level >= 1),
    CONSTRAINT chk_training_session_summaries_reaction
        CHECK (average_reaction_ms IS NULL OR average_reaction_ms >= 0),
    KEY idx_training_session_summaries_user_type_completed (user_id, training_type, completed_at),
    KEY idx_training_session_summaries_user_type_category_completed (user_id, training_type, category, completed_at)
) ENGINE=InnoDB;

USE report_db;

CREATE TABLE IF NOT EXISTS report_summary (
    report_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    social_score INT NULL,
    safety_score INT NULL,
    focus_score INT NULL,
    document_score INT NULL,
    progress_rate DECIMAL(5,2) NULL,
    readiness_score DECIMAL(5,2) NULL,
    strengths_text TEXT NULL,
    weaknesses_text TEXT NULL,
    comment_text TEXT NULL,
    updated_at DATETIME NOT NULL,
    CONSTRAINT uk_report_summary_user
        UNIQUE (user_id),
    CONSTRAINT chk_report_summary_social
        CHECK (social_score IS NULL OR social_score BETWEEN 0 AND 100),
    CONSTRAINT chk_report_summary_safety
        CHECK (safety_score IS NULL OR safety_score BETWEEN 0 AND 100),
    CONSTRAINT chk_report_summary_focus
        CHECK (focus_score IS NULL OR focus_score BETWEEN 0 AND 100),
    CONSTRAINT chk_report_summary_document
        CHECK (document_score IS NULL OR document_score BETWEEN 0 AND 100),
    CONSTRAINT chk_report_summary_progress
        CHECK (progress_rate IS NULL OR progress_rate BETWEEN 0 AND 100),
    CONSTRAINT chk_report_summary_readiness
        CHECK (readiness_score IS NULL OR readiness_score BETWEEN 0 AND 100)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS report_snapshots (
    snapshot_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    report_id BIGINT NOT NULL,
    snapshot_json JSON NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_report_snapshots_report
        FOREIGN KEY (report_id) REFERENCES report_summary(report_id),
    KEY idx_report_snapshots_report (report_id)
) ENGINE=InnoDB;
