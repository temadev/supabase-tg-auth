-- CreateEnum
CREATE TYPE "CompanyType" AS ENUM ('SPECIALIST', 'INVESTOR', 'STARTUP', 'PUBLISHER');

-- CreateTable
CREATE TABLE "user" (
    "id" TEXT NOT NULL,
    "auth_id" TEXT NOT NULL,
    "handle" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "profile_picture" TEXT,
    "roles" TEXT[],
    "lastSwipe" TIMESTAMP(3) NOT NULL DEFAULT '1970-01-01T00:00:00Z'::timestamp,
    "swipesLeft" SMALLINT NOT NULL DEFAULT 0,

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project" (
    "id" TEXT NOT NULL,
    "name" VARCHAR(30) NOT NULL,
    "oneliner" VARCHAR(250),
    "square_logo_black" TEXT,
    "square_logo_white" TEXT,
    "wide_logo_black" TEXT,
    "wide_logo_white" TEXT,
    "origin" TEXT,
    "domains" TEXT[],
    "project_type" "CompanyType" NOT NULL DEFAULT 'STARTUP',
    "ownerId" TEXT NOT NULL,

    CONSTRAINT "project_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "curated_list" (
    "id" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" VARCHAR(500),

    CONSTRAINT "curated_list_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "swipe" (
    "id" TEXT NOT NULL,
    "gen" SMALLINT NOT NULL DEFAULT 0,
    "isLiked" BOOLEAN NOT NULL,
    "inProjectId" TEXT NOT NULL,
    "outProjectId" TEXT NOT NULL,

    CONSTRAINT "swipe_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "match" (
    "id" TEXT NOT NULL,
    "inProjectId" TEXT NOT NULL,
    "outProjectId" TEXT NOT NULL,
    "swipeInId" TEXT NOT NULL,
    "swipeOutId" TEXT NOT NULL,

    CONSTRAINT "match_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "badge" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "popularity" SMALLINT NOT NULL DEFAULT 0,

    CONSTRAINT "badge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_ProjectManagers" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ProjectManagers_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_CuratedListProjects" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_CuratedListProjects_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_BadgeToProject" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_BadgeToProject_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_auth_id_key" ON "user"("auth_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_handle_key" ON "user"("handle");

-- CreateIndex
CREATE UNIQUE INDEX "badge_slug_key" ON "badge"("slug");

-- CreateIndex
CREATE INDEX "_ProjectManagers_B_index" ON "_ProjectManagers"("B");

-- CreateIndex
CREATE INDEX "_CuratedListProjects_B_index" ON "_CuratedListProjects"("B");

-- CreateIndex
CREATE INDEX "_BadgeToProject_B_index" ON "_BadgeToProject"("B");

-- AddForeignKey
ALTER TABLE "project" ADD CONSTRAINT "project_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "swipe" ADD CONSTRAINT "swipe_inProjectId_fkey" FOREIGN KEY ("inProjectId") REFERENCES "project"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "swipe" ADD CONSTRAINT "swipe_outProjectId_fkey" FOREIGN KEY ("outProjectId") REFERENCES "project"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "match" ADD CONSTRAINT "match_inProjectId_fkey" FOREIGN KEY ("inProjectId") REFERENCES "project"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "match" ADD CONSTRAINT "match_outProjectId_fkey" FOREIGN KEY ("outProjectId") REFERENCES "project"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "match" ADD CONSTRAINT "match_swipeInId_fkey" FOREIGN KEY ("swipeInId") REFERENCES "swipe"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "match" ADD CONSTRAINT "match_swipeOutId_fkey" FOREIGN KEY ("swipeOutId") REFERENCES "swipe"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ProjectManagers" ADD CONSTRAINT "_ProjectManagers_A_fkey" FOREIGN KEY ("A") REFERENCES "project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ProjectManagers" ADD CONSTRAINT "_ProjectManagers_B_fkey" FOREIGN KEY ("B") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_CuratedListProjects" ADD CONSTRAINT "_CuratedListProjects_A_fkey" FOREIGN KEY ("A") REFERENCES "curated_list"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_CuratedListProjects" ADD CONSTRAINT "_CuratedListProjects_B_fkey" FOREIGN KEY ("B") REFERENCES "project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_BadgeToProject" ADD CONSTRAINT "_BadgeToProject_A_fkey" FOREIGN KEY ("A") REFERENCES "badge"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_BadgeToProject" ADD CONSTRAINT "_BadgeToProject_B_fkey" FOREIGN KEY ("B") REFERENCES "project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
